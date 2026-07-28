# frozen_string_literal: true

class PlayerActivityLogger
  class << self
    def log!(user, activity_type, game_map: nil, payload: {}, ref: nil, occurred_at: Time.current)
      PlayerActivityLog.create!(
        user: user,
        game_map: game_map,
        activity_type: activity_type.to_s,
        ref_type: ref&.class&.name,
        ref_id: ref&.id&.to_s,
        payload: payload,
        occurred_at: occurred_at
      )
    end
  end
end
