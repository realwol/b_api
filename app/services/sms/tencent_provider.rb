# frozen_string_literal: true

require "net/http"
require "json"
require "securerandom"
require "digest"

module Sms
  class TencentProvider
    ENDPOINT = "https://sms.tencentcloudapi.com"

    def configured?
      %w[TENCENT_SECRET_ID TENCENT_SECRET_KEY TENCENT_SMS_SDK_APP_ID TENCENT_SMS_SIGN TENCENT_SMS_TEMPLATE_ID]
        .all? { |k| ENV[k].present? }
    end

    def deliver(phone:, code:, **_opts)
      raise ApiError.new("腾讯云短信未配置", status: :service_unavailable) unless configured?

      payload = {
        PhoneNumberSet: ["+86#{phone}"],
        SmsSdkAppId: ENV.fetch("TENCENT_SMS_SDK_APP_ID"),
        SignName: ENV.fetch("TENCENT_SMS_SIGN"),
        TemplateId: ENV.fetch("TENCENT_SMS_TEMPLATE_ID"),
        TemplateParamSet: [code]
      }.to_json

      timestamp = Time.now.to_i
      date = Time.at(timestamp).utc.strftime("%Y-%m-%d")
      service = "sms"
      headers = {
        "Content-Type" => "application/json; charset=utf-8",
        "Host" => "sms.tencentcloudapi.com",
        "X-TC-Action" => "SendSms",
        "X-TC-Version" => "2021-01-11",
        "X-TC-Region" => ENV.fetch("TENCENT_SMS_REGION", "ap-guangzhou"),
        "X-TC-Timestamp" => timestamp.to_s
      }

      authorization = tc3_authorization(headers, payload, date, service, timestamp)
      headers["Authorization"] = authorization

      uri = URI(ENDPOINT)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      req = Net::HTTP::Post.new(uri, headers)
      req.body = payload
      response = http.request(req)
      data = JSON.parse(response.body) rescue {}

      if data.dig("Response", "Error")
        msg = data.dig("Response", "Error", "Message") || "短信发送失败"
        Rails.logger.error "[SMS:Tencent] #{data}"
        raise ApiError.new(msg, status: :bad_gateway)
      end

      :sent
    end

    private

    def tc3_authorization(headers, payload, date, service, timestamp)
      secret_id = ENV.fetch("TENCENT_SECRET_ID")
      secret_key = ENV.fetch("TENCENT_SECRET_KEY")
      canonical_request = [
        "POST",
        "/",
        "",
        "content-type:#{headers['Content-Type']}\nhost:#{headers['Host']}\n",
        "content-type;host",
        Digest::SHA256.hexdigest(payload)
      ].join("\n")
      credential_scope = "#{date}/#{service}/tc3_request"
      string_to_sign = [
        "TC3-HMAC-SHA256",
        timestamp.to_s,
        credential_scope,
        Digest::SHA256.hexdigest(canonical_request)
      ].join("\n")
      secret_date = hmac("TC3#{secret_key}", date)
      secret_service = hmac(secret_date, service)
      secret_signing = hmac(secret_service, "tc3_request")
      signature = hmac_hex(secret_signing, string_to_sign)
      "TC3-HMAC-SHA256 Credential=#{secret_id}/#{credential_scope}, SignedHeaders=content-type;host, Signature=#{signature}"
    end

    def hmac(key, msg)
      OpenSSL::HMAC.digest("sha256", key, msg)
    end

    def hmac_hex(key, msg)
      OpenSSL::HMAC.hexdigest("sha256", key, msg)
    end
  end
end
