# frozen_string_literal: true

class SmsCode < ApplicationRecord
  validates :phone, :code, :expires_at, presence: true

  scope :active, -> { where("expires_at > ?", Time.current) }

  def self.issue!(phone, code, ttl: 5.minutes)
    transaction do
      where(phone: phone).delete_all
      create!(phone: phone, code: code, expires_at: ttl.from_now)
    end
  end

  def self.verify!(phone, code)
    record = active.find_by(phone: phone, code: code.to_s.strip)
    raise ApiError.new("验证码错误或已过期", status: :unauthorized) unless record

    record.destroy
    phone
  end

  def self.too_soon?(phone, interval: 60.seconds)
    last = where(phone: phone).order(created_at: :desc).first
    last.present? && last.created_at > interval.ago
  end
end
