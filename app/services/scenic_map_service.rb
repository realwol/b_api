# frozen_string_literal: true

class ScenicMapService
  class << self
    def list_scenic_maps(user)
      GameMap.active.where(map_type: "scenic").order(:id).map do |map|
        map.as_json.merge(
          unlocked: user.user_level >= map.unlock_level,
          trigger_point_count: map.map_trigger_points.active.count,
          task_count: map.map_tasks.active.count
        )
      end
    end

    def enter!(user, map_id:)
      game_map = GameMap.active.find(map_id)
      raise ApiError, "该地图不是景区地图" unless game_map.map_type == "scenic"

      result = MapService.enter!(user, map_id: map_id)

      PlayerActivityLogger.log!(
        user, :map_enter, game_map: game_map,
        payload: { map_type: "scenic", map_name: game_map.name }
      )

      result.merge(
        map_type: "scenic",
        route_image_url: game_map.route_image_url || game_map.background_url,
        route_polyline: game_map.route_polyline,
        bounds_geo: game_map.bounds_geo,
        center: { lat: game_map.center_lat, lng: game_map.center_lng },
        trigger_points: game_map.map_trigger_points.active.order(:sort_order).map(&:as_json),
        tasks: map_tasks_payload(user, game_map)
      )
    end

    def check_location!(user, map_id:, latitude:, longitude:)
      game_map = GameMap.active.find(map_id)
      raise ApiError, "该地图不是景区地图" unless game_map.map_type == "scenic"

      lat = latitude.to_f
      lng = longitude.to_f
      matched = game_map.map_trigger_points.active.select { |p| p.gps? && p.within_radius?(lat, lng) }

      PlayerActivityLogger.log!(
        user, :gps_enter, game_map: game_map,
        payload: { latitude: lat, longitude: lng, matched_keys: matched.map(&:key) }
      )

      triggers = matched.map do |point|
        trigger_at_point!(user, game_map, point, source: "gps", extra: { latitude: lat, longitude: lng })
      end

      { matched: matched.map(&:as_json), triggers: triggers.compact }
    end

    def check_beacon!(user, map_id:, uuid:, major: nil, minor: nil, rssi: nil)
      game_map = GameMap.active.find(map_id)
      raise ApiError, "该地图不是景区地图" unless game_map.map_type == "scenic"

      matched = game_map.map_trigger_points.active.select do |p|
        p.bluetooth? && p.matches_beacon?(uuid: uuid, major: major, minor: minor)
      end

      PlayerActivityLogger.log!(
        user, :ble_detect, game_map: game_map,
        payload: { uuid: uuid, major: major, minor: minor, rssi: rssi, matched_keys: matched.map(&:key) }
      )

      triggers = matched.map do |point|
        trigger_at_point!(user, game_map, point, source: "bluetooth",
                          extra: { uuid: uuid, major: major, minor: minor, rssi: rssi })
      end

      { matched: matched.map(&:as_json), triggers: triggers.compact }
    end

    def complete_task!(user, map_id:, task_id:, score: 0, result_data: {})
      game_map = GameMap.active.find(map_id)
      task = game_map.map_tasks.active.find(task_id)
      progress = user.user_map_task_progresses.find_or_initialize_by(game_map: game_map, map_task: task)

      raise ApiError, "任务已完成" if progress.status == "completed"

      progress.status = "in_progress" if progress.new_record? || progress.status == "locked"
      progress.best_score = [progress.best_score, score.to_i].max
      progress.progress_data = (progress.progress_data || {}).merge(result_data.stringify_keys)
      progress.save!

      PlayerActivityLogger.log!(
        user, :task_start, game_map: game_map, ref: task,
        payload: { task_key: task.key, score: score.to_i }
      )

      rewards_config = task.rewards_for_score(score.to_i)
      granted = {}
      if rewards_config.present?
        granted = EventRewardService.grant!(
          user,
          rewards_config,
          source_description: "景区任务：#{task.name}",
          game_map: game_map,
          ref: task
        )
      end

      progress.update!(status: "completed", completed_at: Time.current, best_score: score.to_i)

      PlayerActivityLogger.log!(
        user, :task_complete, game_map: game_map, ref: task,
        payload: { score: score.to_i, result_data: result_data, rewards: granted }
      )

      { task: task.as_json, progress: progress.reload.as_json, rewards: granted }
    end

    private

    def map_tasks_payload(user, game_map)
      game_map.map_tasks.active.order(:sort_order).map do |task|
        progress = user.user_map_task_progresses.find_by(map_task: task)
        task.as_json.merge(
          progress: progress&.as_json,
          trigger_point: task.map_trigger_point&.as_json
        )
      end
    end

    def trigger_at_point!(user, game_map, point, source:, extra: {})
      task = game_map.map_tasks.active.find_by(map_trigger_point: point)
      if task
        progress = user.user_map_task_progresses.find_or_initialize_by(game_map: game_map, map_task: task)
        unless progress.status == "completed"
          progress.update!(status: "available") if progress.status.in?(%w[locked])
          progress.update!(status: "in_progress") if progress.status == "available"
        end
      end

      event_result = nil
      if point.event_template
        state = user.user_map_states.find_by(game_map: game_map)
        pos_x = point.map_x
        pos_y = point.map_y
        event_result = MapEventService.roll_event!(
          user,
          game_map: game_map,
          pos_x: pos_x,
          pos_y: pos_y,
          trigger_source: source,
          sensor_key: point.key,
          template: point.event_template
        )
      end

      PlayerActivityLogger.log!(
        user, :sensor_trigger, game_map: game_map, ref: point,
        payload: { trigger_key: point.key, source: source, extra: extra, event_id: event_result&.dig(:event, "id") }
      )

      {
        trigger_point: point.as_json,
        task: task&.as_json,
        event: event_result
      }
    end
  end
end
