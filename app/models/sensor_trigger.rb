# frozen_string_literal: true

class SensorTrigger < ApplicationRecord
  belongs_to :event_template
  belongs_to :game_map, optional: true

  SENSOR_TYPES = %w[
    motion proximity temperature humidity light sound accelerometer gyroscope custom
  ].freeze

  validates :key, :name, :sensor_type, presence: true
  validates :key, uniqueness: true
  validates :sensor_type, inclusion: { in: SENSOR_TYPES }

  scope :active, -> { where(is_active: true) }

  def matches_value?(value)
    range = value_range || {}
    min = range["min"] || range[:min]
    max = range["max"] || range[:max]
    return true if min.nil? && max.nil?

    num = value.to_f
    (min.nil? || num >= min.to_f) && (max.nil? || num <= max.to_f)
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :key, :name, :description, :sensor_type, :value_range,
             :event_template_id, :game_map_id, :priority, :config, :is_active]
    ))
  end
end
