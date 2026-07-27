# frozen_string_literal: true

class Character < ApplicationRecord
  belongs_to :user
  has_many :care_logs, dependent: :destroy

  STAGES = %w[baby child teen adult].freeze
  STAT_CAP = 100
  MAX_LEVEL = 50

  validates :name, presence: true
  validates :level, numericality: { in: 1..MAX_LEVEL }
  validates :stage, inclusion: { in: STAGES }
  validates :mood, :energy, :hunger, numericality: { in: 0..STAT_CAP }
  validates :charm, :intelligence, :affection, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(is_active: true) }

  APPEARANCE_OPTIONS = {
    "gender" => %w[female male],
    "hairstyle" => %w[long_black short_brown twin_tail curly_blonde ponytail],
    "personality" => %w[gentle lively cool elegant],
    "face" => %w[round oval heart square],
    "height" => %w[petite medium tall]
  }.freeze

  DEFAULT_APPEARANCE = {
    "gender" => "female",
    "hairstyle" => "long_black",
    "personality" => "gentle",
    "face" => "round",
    "height" => "medium",
    "hair" => "long_black",
    "outfit" => "default_dress",
    "skin_tone" => "fair",
    "accessory" => "ribbon",
    "customized" => false
  }.freeze

  def customized?
    appearance.is_a?(Hash) && appearance["customized"] == true
  end

  def needs_customization?
    !customized?
  end

  EXP_PER_LEVEL = 100

  def exp_to_next_level
    level * EXP_PER_LEVEL
  end

  def add_exp!(amount)
    self.exp += amount
    while exp >= exp_to_next_level && level < MAX_LEVEL
      self.exp -= exp_to_next_level
      self.level += 1
      update_stage!
    end
    save!
  end

  def update_stage!
    new_stage = STAGES.reverse.find { |s| level >= User::STAGE_THRESHOLDS[s] } || "baby"
    self.stage = new_stage
  end

  def apply_stat_decay!
    hours_since_care = last_cared_at ? ((Time.current - last_cared_at) / 1.hour).floor : 24
    return if hours_since_care < 1

    decay = [hours_since_care, 12].min
    self.mood = [mood - decay, 0].max
    self.energy = [energy - decay, 0].max
    self.hunger = [hunger + decay, STAT_CAP].min
    save!
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :appearance, :level, :exp, :stage, :charm, :intelligence,
             :mood, :energy, :hunger, :affection, :is_active, :last_cared_at],
      methods: [:exp_to_next_level]
    ))
  end
end
