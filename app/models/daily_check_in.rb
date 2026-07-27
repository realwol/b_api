# frozen_string_literal: true

class DailyCheckIn < ApplicationRecord
  belongs_to :user

  validates :check_in_date, presence: true
  validates :check_in_date, uniqueness: { scope: :user_id }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :check_in_date, :reward_coins, :reward_gems, :streak_day]
    ))
  end
end
