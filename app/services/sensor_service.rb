# frozen_string_literal: true

class SensorService
  class << self
    def trigger!(sensor_type:, sensor_value:, user: nil, user_id: nil, sensor_key: nil, map_id: nil)
      user ||= User.find(user_id) if user_id
      raise ApiError, "用户不存在" unless user

      triggers = SensorTrigger.active
                              .where(sensor_type: sensor_type)
                              .order(priority: :desc)

      trigger = triggers.find { |t| t.matches_value?(sensor_value) }
      raise ApiError, "无匹配的传感器触发配置" unless trigger

      if sensor_key.present?
        matched = triggers.find { |t| t.key == sensor_key }
        trigger = matched if matched
      end

      template = trigger.event_template
      raise ApiError, "关联事件未启用" unless template.is_active?
      raise ApiError, "该事件不支持传感器触发" unless template.sensor_triggerable?

      game_map = resolve_map(user, trigger, map_id)
      state = user.user_map_states.find_by(game_map: game_map)
      pos_x = state&.pos_x || game_map.width / 2
      pos_y = state&.pos_y || game_map.height / 2
      zone = game_map.map_zones.active.find { |z| z.contains?(pos_x, pos_y) }

      MapEventService.roll_event!(
        user,
        game_map: game_map,
        pos_x: pos_x,
        pos_y: pos_y,
        zone: zone,
        trigger_source: "sensor",
        sensor_key: trigger.key
      ).merge(sensor_trigger: trigger.as_json)
    end

    private

    def resolve_map(user, trigger, map_id)
      if map_id
        GameMap.active.find(map_id)
      elsif trigger.game_map
        trigger.game_map
      else
        user.user_map_states.order(updated_at: :desc).first&.game_map || GameMap.default_map
      end
    end
  end
end
