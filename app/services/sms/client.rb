# frozen_string_literal: true

module Sms
  class Client
    class << self
      def deliver!(phone:, code:)
        provider = build_provider
        unless provider.configured?
          raise ApiError.new("短信服务未配置，请联系管理员", status: :service_unavailable)
        end

        provider.deliver(phone: phone, code: code)
      end

      def provider_name
        ENV.fetch("SMS_PROVIDER", default_provider).downcase
      end

      private

      def default_provider
        Rails.env.production? ? "aliyun" : "log"
      end

      def build_provider
        case provider_name
        when "aliyun" then AliyunProvider.new
        when "tencent" then TencentProvider.new
        else LogProvider.new
        end
      end
    end
  end
end
