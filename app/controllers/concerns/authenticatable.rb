# frozen_string_literal: true

module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.remove(/^Bearer /)
    @current_user = AuthService.find_user_by_token(token)
    render json: { error: "请先登录" }, status: :unauthorized unless @current_user
  end

  def current_user
    @current_user
  end
end
