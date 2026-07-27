# frozen_string_literal: true

module AdminAuthenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_admin!
  end

  private

  def authenticate_admin!
    key = request.headers["X-Admin-Key"]
    expected = ENV.fetch("ADMIN_API_KEY", "dev_admin_key")
    render json: { error: "管理密钥无效" }, status: :unauthorized unless key.present? && key == expected
  end
end
