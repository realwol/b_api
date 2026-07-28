# frozen_string_literal: true

class MapService
  class << self
    def enter!(user, map_id: nil)
      game_map = map_id ? GameMap.active.find(map_id) : GameMap.default_map
      raise ApiError, "地图不存在" unless game_map
      raise ApiError, "等级不足，需要 Lv.#{game_map.unlock_level}" if user.user_level < game_map.unlock_level

      spawn = default_spawn(game_map)
      state = user.user_map_states.find_or_initialize_by(game_map: game_map)
      state.pos_x = spawn[:x] if state.new_record?
      state.pos_y = spawn[:y] if state.new_record?
      state.entered_at = Time.current
      state.save!

      PlayerActivityLogger.log!(
        user, :map_enter, game_map: game_map,
        payload: { map_type: game_map.map_type, pos_x: state.pos_x, pos_y: state.pos_y }
      )

      pending = user.user_map_events.active_events.where(game_map: game_map).map(&:as_json)

      payload = {
        map: game_map.as_json,
        state: state.as_json,
        zones: game_map.map_zones.active.map(&:as_json),
        spawn_points: game_map.map_spawn_points.active.map(&:as_json),
        pending_events: pending
      }

      if game_map.scenic?
        payload.merge!(
          route_image_url: game_map.route_image_url || game_map.background_url,
          route_polyline: game_map.route_polyline,
          bounds_geo: game_map.bounds_geo,
          center: { lat: game_map.center_lat, lng: game_map.center_lng },
          trigger_points: game_map.map_trigger_points.active.order(:sort_order).map(&:as_json),
          tasks: game_map.map_tasks.active.order(:sort_order).map(&:as_json)
        )
      end

      payload
    end

    def current(user)
      state = user.user_map_states.order(updated_at: :desc).first
      return { map: nil, state: nil } unless state

      game_map = state.game_map
      {
        map: game_map.as_json,
        state: state.as_json,
        zones: game_map.map_zones.active.map(&:as_json),
        pending_events: user.user_map_events.active_events.where(game_map: game_map).map(&:as_json)
      }
    end

    def move!(user, map_id:, pos_x:, pos_y:)
      game_map = GameMap.find(map_id)
      state = user.user_map_states.find_by!(user: user, game_map: game_map)

      pos_x = [[pos_x.to_i, 0].max, game_map.width].min
      pos_y = [[pos_y.to_i, 0].max, game_map.height].min

      state.update!(pos_x: pos_x, pos_y: pos_y)
      zone = game_map.map_zones.active.find { |z| z.contains?(pos_x, pos_y) }

      { state: state.as_json, zone: zone&.as_json }
    end

    def explore!(user, map_id: nil)
      state = if map_id
                user.user_map_states.find_by!(game_map_id: map_id)
              else
                user.user_map_states.order(updated_at: :desc).first
              end
      raise ApiError, "请先进入地图" unless state

      game_map = state.game_map
      if game_map.spawn_interval_minutes.positive? && state.last_explored_at
        elapsed = (Time.current - state.last_explored_at) / 60
        remaining = game_map.spawn_interval_minutes - elapsed
        raise ApiError, "探索冷却中，请 #{remaining.ceil} 分钟后再试" if remaining > 0
      end

      zone = game_map.map_zones.active.find { |z| z.contains?(state.pos_x, state.pos_y) }
      result = MapEventService.roll_event!(
        user,
        game_map: game_map,
        pos_x: state.pos_x,
        pos_y: state.pos_y,
        zone: zone,
        trigger_source: "explore"
      )

      state.update!(last_explored_at: Time.current, explore_count: state.explore_count + 1)
      result.merge(state: state.reload.as_json, zone: zone&.as_json)
    end

    private

    def default_spawn(game_map)
      point = game_map.map_spawn_points.active.find_by(is_random: false)
      return { x: point.x, y: point.y } if point

      { x: game_map.width / 2, y: game_map.height / 2 }
    end
  end
end
