# frozen_string_literal: true

class User < ApplicationRecord
  has_secure_password validations: false

  has_many :characters, dependent: :destroy
  has_many :user_items, dependent: :destroy
  has_many :items, through: :user_items
  has_many :user_story_progresses, dependent: :destroy
  has_many :daily_check_ins, dependent: :destroy
  has_many :user_achievements, dependent: :destroy
  has_many :achievements, through: :user_achievements
  has_many :coin_transactions, dependent: :destroy
  has_many :exp_records, dependent: :destroy
  has_many :user_learning_progresses, dependent: :destroy
  has_many :user_skill_levels, dependent: :destroy
  has_many :user_decorations, dependent: :destroy
  has_one :user_room, dependent: :destroy
  has_many :user_map_states, dependent: :destroy
  has_many :user_map_events, dependent: :destroy

  validates :openid, presence: true, uniqueness: true
  validates :account, uniqueness: { case_sensitive: false }, allow_nil: true
  validates :phone, uniqueness: true, allow_nil: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validates :coins, :gems, :total_exp, numericality: { greater_than_or_equal_to: 0 }
  validates :user_level, numericality: { greater_than_or_equal_to: 1 }

  before_create :generate_auth_token

  EXP_PER_USER_LEVEL = 200

  STAGE_THRESHOLDS = {
    "baby" => 1,
    "child" => 5,
    "teen" => 15,
    "adult" => 30
  }.freeze

  def active_character
    characters.find_by(is_active: true) || characters.first
  end

  def regenerate_auth_token!
    update!(auth_token: SecureRandom.hex(32))
  end

  def exp_to_next_level
    user_level * EXP_PER_USER_LEVEL
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :account, :phone, :nickname, :avatar_url, :coins, :gems, :login_streak,
             :last_check_in_at, :tutorial_completed, :user_level, :total_exp],
      methods: [:checked_in_today?, :exp_to_next_level]
    ))
  end

  def checked_in_today?
    last_check_in_at&.to_date == Date.current
  end

  private

  def generate_auth_token
    self.auth_token = SecureRandom.hex(32)
  end
end
