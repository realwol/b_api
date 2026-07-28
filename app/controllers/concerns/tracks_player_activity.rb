# frozen_string_literal: true

module TracksPlayerActivity
  extend ActiveSupport::Concern

  included do
    after_action :track_player_api_request
  end

  private

  def track_player_api_request
    return unless response.successful?
    return if self.class.name.include?("Admin::")
    return if controller_name == "tracking"
    return if controller_name == "auth" && action_name.in?(%w[login register send_sms])

    user = tracking_current_user
    return unless user

    PlayerActivityLogger.log_api!(
      user: user,
      request: request,
      controller: controller_name,
      action_name: action_name,
      params: params,
      status_code: response.status,
      game_map_id: params[:map_id] || params[:game_map_id]
    )
  rescue StandardError => e
    Rails.logger.warn("[TracksPlayerActivity] #{e.message}")
  end

  def tracking_current_user
    return current_user if respond_to?(:current_user, true) && current_user
    return @current_user if defined?(@current_user) && @current_user

    token = request.headers["Authorization"]&.remove(/^Bearer /)
    AuthService.find_user_by_token(token)
  end
end
