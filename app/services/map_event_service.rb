# frozen_string_literal: true

class MapEventService
  class << self
    def roll_event!(user, game_map:, pos_x:, pos_y:, zone: nil, trigger_source: "explore", sensor_key: nil, template: nil)
      zone ||= find_zone(game_map, pos_x, pos_y)
      template ||= weighted_random(eligible_templates(user, game_map, zone))

      raise ApiError, "此区域暂无可用事件" unless template
      position = resolve_position(game_map, zone, pos_x, pos_y)

      event = user.user_map_events.create!(
        event_template: template,
        game_map: game_map,
        map_zone: zone,
        status: "pending",
        trigger_source: trigger_source,
        pos_x: position[:x],
        pos_y: position[:y],
        event_snapshot: template.as_json,
        sensor_key: sensor_key
      )

      { event: event.as_json, template: template.as_json, zone: zone&.as_json }
    end

    def start!(user, event)
      raise ApiError, "事件不存在" unless event.user_id == user.id
      raise ApiError, "事件状态无效" unless event.status == "pending"

      event.update!(status: "in_progress", started_at: Time.current)
      PlayerActivityLogger.log!(
        user, :task_start, game_map: event.game_map, ref: event,
        payload: { event_name: event.event_template&.name, trigger_source: event.trigger_source }
      )
      { event: event.reload.as_json }
    end

    def complete!(user, event, outcome: "success", result_data: {})
      raise ApiError, "事件不存在" unless event.user_id == user.id
      raise ApiError, "请先开始事件" unless event.status == "in_progress"

      template = event.event_template
      granted = {}

      if outcome.to_s == "success"
        granted = EventRewardService.grant!(
          user,
          template.rewards_config,
          source_description: "地图事件：#{template.name}",
          game_map: event.game_map,
          ref: event
        )
        AchievementService.check!(user, :user_level)
      end

      event.update!(
        status: outcome.to_s == "success" ? "completed" : "failed",
        completed_at: Time.current,
        rewards_granted: granted,
        result_data: result_data
      )

      PlayerActivityLogger.log!(
        user, :task_complete, game_map: event.game_map, ref: event,
        payload: { outcome: outcome, rewards: granted, result_data: result_data }
      )

      {
        event: event.reload.as_json,
        rewards: granted,
        user: user.reload.as_json
      }
    end

    def list_for(user, status: nil)
      scope = user.user_map_events.order(created_at: :desc)
      scope = scope.where(status: status) if status.present?
      scope.limit(50).map(&:as_json)
    end

    def eligible_templates(user, game_map, zone)
      EventTemplate.active.select do |t|
        template_eligible?(user, t, game_map, zone)
      end
    end

    private

    def template_eligible?(user, template, game_map, zone)
      return false if template.game_map_id.present? && template.game_map_id != game_map.id
      return false if template.map_zone_id.present? && template.map_zone_id != zone&.id
      return false if user.user_level < template.min_user_level
      return false if user.user_level > template.max_user_level

      if template.cooldown_minutes.positive?
        last = user.user_map_events
                    .where(event_template: template, status: "completed")
                    .order(completed_at: :desc).first
        if last&.completed_at && last.completed_at > template.cooldown_minutes.minutes.ago
          return false
        end
      end

      conditions = template.trigger_conditions || {}
      if conditions["max_daily"].present?
        today_count = user.user_map_events
                          .where(event_template: template)
                          .where("created_at >= ?", Date.current.beginning_of_day)
                          .count
        return false if today_count >= conditions["max_daily"].to_i
      end

      true
    end

    def weighted_random(templates)
      total = templates.sum(&:trigger_weight)
      roll = rand(total)
      cumulative = 0
      templates.each do |t|
        cumulative += t.trigger_weight
        return t if roll < cumulative
      end
      templates.last
    end

    def find_zone(game_map, x, y)
      game_map.map_zones.active.find { |z| z.contains?(x, y) }
    end

    def resolve_position(game_map, zone, x, y)
      spawn = game_map.map_spawn_points.active.where(is_random: true).sample
      return { x: spawn.x, y: spawn.y } if spawn

      return zone.random_point if zone

      { x: rand(0..game_map.width), y: rand(0..game_map.height) }
    end
  end
end
