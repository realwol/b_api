# frozen_string_literal: true

require "net/http"
require "openssl"
require "securerandom"

module Sms
  class AliyunProvider
    ENDPOINT = "https://dysmsapi.aliyuncs.com/"

    def configured?
      %w[ALIYUN_ACCESS_KEY_ID ALIYUN_ACCESS_KEY_SECRET ALIYUN_SMS_SIGN_NAME ALIYUN_SMS_TEMPLATE_CODE]
        .all? { |k| ENV[k].present? }
    end

    def deliver(phone:, code:, **_opts)
      raise ApiError.new("阿里云短信未配置", status: :service_unavailable) unless configured?

      params = {
        "Action" => "SendSms",
        "Format" => "JSON",
        "Version" => "2017-05-25",
        "AccessKeyId" => ENV.fetch("ALIYUN_ACCESS_KEY_ID"),
        "SignatureMethod" => "HMAC-SHA1",
        "SignatureVersion" => "1.0",
        "SignatureNonce" => SecureRandom.uuid,
        "Timestamp" => Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ"),
        "PhoneNumbers" => phone,
        "SignName" => ENV.fetch("ALIYUN_SMS_SIGN_NAME"),
        "TemplateCode" => ENV.fetch("ALIYUN_SMS_TEMPLATE_CODE"),
        "TemplateParam" => { code: code }.to_json
      }
      params["Signature"] = sign(params)

      uri = URI(ENDPOINT)
      uri.query = URI.encode_www_form(params.sort.to_h)
      response = Net::HTTP.get_response(uri)
      data = JSON.parse(response.body) rescue {}

      unless data["Code"] == "OK"
        Rails.logger.error "[SMS:Aliyun] #{data}"
        raise ApiError.new(data["Message"].presence || "短信发送失败", status: :bad_gateway)
      end

      :sent
    end

    private

    def sign(params)
      canonical = params.sort.map do |k, v|
        "#{encode(k)}=#{encode(v)}"
      end.join("&")
      string_to_sign = "GET&#{encode('/')}&#{encode(canonical)}"
      key = "#{ENV.fetch('ALIYUN_ACCESS_KEY_SECRET')}&"
      Base64.strict_encode64(OpenSSL::HMAC.digest("sha1", key, string_to_sign))
    end

    def encode(value)
      URI.encode_www_form_component(value.to_s).gsub("+", "%20").gsub("*", "%2A").gsub("%7E", "~")
    end
  end
end
