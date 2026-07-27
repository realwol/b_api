# frozen_string_literal: true

module SmsAuthService
  CODE_TTL = 5.minutes
  RESEND_INTERVAL = 60.seconds

  class << self
    def send_code(phone:)
      normalized = normalize_phone!(phone)
      if SmsCode.too_soon?(normalized, interval: RESEND_INTERVAL)
        raise ApiError.new("发送太频繁，请 #{RESEND_INTERVAL.to_i} 秒后再试", status: :too_many_requests)
      end

      code = format("%06d", rand(0..999_999))
      delivery = Sms::Client.deliver!(phone: normalized, code: code)
      SmsCode.issue!(normalized, code, ttl: CODE_TTL)

      result = { ok: true, message: "验证码已发送，请注意查收短信" }
      result[:dev_code] = code if delivery == :logged
      result
    end

    def verify!(phone:, code:)
      normalized = normalize_phone!(phone)
      SmsCode.verify!(normalized, code)
    end

    private

    def normalize_phone!(phone)
      digits = phone.to_s.gsub(/\D/, "")
      raise ApiError.new("请输入11位中国大陆手机号", status: :unprocessable_entity) unless digits.match?(/\A1[3-9]\d{9}\z/)

      digits
    end
  end
end
