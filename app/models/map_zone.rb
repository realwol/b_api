# frozen_string_literal: true

class MapZone < ApplicationRecord
  belongs_to :game_map
  has_many :map_spawn_points, dependent: :nullify
  has_many :event_templates, dependent: :nullify

  ZONE_TYPES = %w[normal forest mountain cave town secret battle].freeze

  validates :name, presence: true
  validates :zone_type, inclusion: { in: ZONE_TYPES }

  scope :active, -> { where(is_active: true) }

  def contains?(x, y)
    x >= x_min && x <= x_max && y >= y_min && y <= y_max
  end

  def random_point
    { x: rand(x_min..x_max), y: rand(y_min..y_max) }
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :game_map_id, :name, :zone_type, :x_min, :y_min, :x_max, :y_max,
             :spawn_weight, :config, :is_active]
    ))
  end
end
