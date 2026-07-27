# frozen_string_literal: true

class CoinTransaction < ApplicationRecord
  belongs_to :user

  SOURCES = %w[
    daily_check_in story_reward shop_purchase achievement_reward
    learning_reward care_bonus decoration_purchase admin
  ].freeze

  validates :amount, :balance_after, :source, presence: true

  def as_json(options = {})
    super(options.merge(only: [:id, :amount, :balance_after, :source, :description, :created_at]))
  end
end
