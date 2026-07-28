# frozen_string_literal: true

class PlayerActivityLogger
  SENSITIVE_KEYS = %w[password password_confirmation code token auth_token authorization].freeze

  class << self
    def log!(user, activity_type, game_map: nil, payload: {}, ref: nil, occurred_at: Time.current, **extra)
      create_log!(
        user: user,
        activity_type: activity_type,
    category: "business",
    action: extra[:action] || activity_type.to_s,
        page: extra[:page],
        session_id: extra[:session_id],
        request_method: extra[:request_method],
        request_path: extra[:request_path],
        status_code: extra[:status_code],
        success: extra.fetch(:success, true),
        game_map: game_map,
        payload: payload,
        ref: ref,
        occurred_at: occurred_at
      )
    end

    def log_api!(user:, request:, controller:, action_name:, params:, status_code:, game_map_id: nil)
      method = request.request_method
      activity_type = method == "GET" ? "api_read" : "api_request"
      action = "#{controller}##{action_name}"
      page = infer_page_from_params(params)

      create_log!(
        user: user,
        activity_type: activity_type,
        category: "api",
        action: action,
        page: page,
        request_method: method,
        request_path: request.fullpath,
        status_code: status_code,
        success: status_code.to_i < 400,
        game_map: game_map_id.present? ? GameMap.find_by(id: game_map_id) : nil,
        payload: {
          controller: controller,
          action: action_name,
          params: sanitize_params(params)
        }
      )
    end

    def log_client!(user, event)
      data = event.with_indifferent_access
      create_log!(
        user: user,
        activity_type: data[:activity_type].presence || "client_event",
        category: "client",
        action: data[:action],
        page: data[:page],
        session_id: data[:session_id],
        success: data.fetch(:success, true),
        game_map: GameMap.find_by(id: data[:game_map_id]),
        payload: data[:payload] || data.except(:activity_type, :action, :page, :session_id, :occurred_at, :game_map_id),
        occurred_at: parse_time(data[:occurred_at])
      )
    end

    def log_auth!(user, activity_type, payload: {}, request: nil)
      create_log!(
        user: user,
        activity_type: activity_type,
        category: "auth",
        action: activity_type.to_s,
        request_method: request&.request_method,
        request_path: request&.fullpath,
        payload: payload,
        occurred_at: Time.current
      )
    end

    private

    def create_log!(**attrs)
      ref = attrs.delete(:ref)
      game_map = attrs.delete(:game_map)

      PlayerActivityLog.create!(
        user: attrs[:user],
        game_map: game_map,
        category: attrs[:category] || "business",
        activity_type: attrs[:activity_type].to_s,
        action: attrs[:action],
        page: attrs[:page],
        session_id: attrs[:session_id],
        request_method: attrs[:request_method],
        request_path: attrs[:request_path],
        status_code: attrs[:status_code],
        success: attrs.fetch(:success, true),
        ref_type: ref&.class&.name,
        ref_id: ref&.id&.to_s,
        payload: attrs[:payload] || {},
        occurred_at: attrs[:occurred_at] || Time.current
      )
    end

    def sanitize_params(params)
      hash = params.to_unsafe_h.except("controller", "action", "format")
      hash.each_key do |key|
        hash[key] = "[FILTERED]" if SENSITIVE_KEYS.include?(key.to_s.downcase)
      end
      hash
    end

    def infer_page_from_params(params)
      params[:page].presence || params[:panel].presence
    end

    def parse_time(value)
      return Time.current if value.blank?

      Time.zone.parse(value.to_s)
    rescue ArgumentError
      Time.current
    end
  end
end
