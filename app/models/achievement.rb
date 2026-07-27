# frozen_string_literal: true

class Achievement < ApplicationRecord
  has_many :user_achievements, dependent: :destroy
  has_many :users, through: :user_achievements

  CATEGORIES = %w[care story learning decoration economy collection].freeze
  CONDITION_TYPES = %w[
    care_count story_complete check_in_streak user_level
    skill_level decoration_count room_beauty coins_earned learning_complete
  ].freeze

  validates :key, :title, :category, :condition_type, presence: true
  validates :key, uniqueness: true

  def as_json(options = {})
    super(options.merge(
      only: [:id, :key, :title, :description, :category, :condition_type,
             :condition_value, :reward_coins, :reward_gems, :reward_exp, :icon_url]
    ))
  end
end
