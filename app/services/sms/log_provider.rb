# frozen_string_literal: true

module Sms
  class LogProvider
    def deliver(phone:, code:, **_opts)
      Rails.logger.info "[SMS:LOG] phone=#{phone} code=#{code}"
      :logged
    end

    def configured?
      true
    end
  end
end
