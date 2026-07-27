# frozen_string_literal: true

class EventTemplate < ApplicationRecord
  belongs_to :game_map, optional: true
  belongs_to :map_zone, optional: true
  belongs_to :learning_category, optional: true
  has_many :user_map_events, dependent: :restrict_with_error
  has_many :sensor_triggers, dependent: :restrict_with_error

  EVENT_TYPES = %w[
    battle mini_game hermit master heavenly_secret serendipity treasure story
  ].freeze

  validates :key, :name, :event_type, presence: true
  validates :key, uniqueness: true
  validates :event_type, inclusion: { in: EVENT_TYPES }
  validates :difficulty, numericality: { in: 1..10 }

  scope :active, -> { where(is_active: true) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :key, :name, :description, :event_type, :difficulty, :game_map_id,
             :map_zone_id, :learning_category_id, :min_user_level, :max_user_level,
             :trigger_weight, :cooldown_minutes, :content, :rewards_config,
             :trigger_conditions, :sensor_triggerable, :is_active, :sort_order]
    ))
  end
end
