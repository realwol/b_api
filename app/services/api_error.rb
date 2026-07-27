# frozen_string_literal: true

class ApiError < StandardError
  attr_reader :status

  def initialize(message, status: :unprocessable_entity)
    super(message)
    @status = status
  end
end
