# frozen_string_literal: true

class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :not_found
  rescue_from ApiError, with: :api_error
  rescue_from ActiveRecord::RecordInvalid, with: :validation_error

  private

  def not_found
    render json: { error: "资源不存在" }, status: :not_found
  end

  def api_error(exception)
    render json: { error: exception.message }, status: exception.status
  end

  def validation_error(exception)
    render json: { error: exception.record.errors.full_messages.join(", ") }, status: :unprocessable_entity
  end
end
