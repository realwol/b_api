# frozen_string_literal: true

class GameMap < ApplicationRecord
  has_many :map_zones, dependent: :destroy
  has_many :map_spawn_points, dependent: :destroy
  has_many :event_templates, dependent: :nullify
  has_many :user_map_states, dependent: :destroy
  has_many :map_trigger_points, dependent: :destroy
  has_many :map_tasks, dependent: :destroy
  has_many :player_activity_logs, dependent: :nullify

  MAP_TYPES = %w[virtual scenic].freeze

  validates :key, :name, presence: true
  validates :key, uniqueness: true

  scope :active, -> { where(is_active: true) }

  def self.default_map
    active.find_by(is_default: true) || active.order(:id).first
  end

  validates :map_type, inclusion: { in: MAP_TYPES }

  scope :scenic, -> { where(map_type: "scenic") }
  scope :virtual, -> { where(map_type: "virtual") }

  def scenic?
    map_type == "scenic"
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :key, :name, :description, :background_url, :route_image_url,
             :width, :height, :unlock_level, :spawn_interval_minutes, :config,
             :is_active, :is_default, :map_type, :center_lat, :center_lng,
             :default_zoom, :bounds_geo, :route_polyline, :address, :city, :region]
    ))
  end
end
