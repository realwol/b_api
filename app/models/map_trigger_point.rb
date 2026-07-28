# frozen_string_literal: true

class MapTriggerPoint < ApplicationRecord
  belongs_to :game_map
  belongs_to :event_template, optional: true
  has_many :map_tasks, dependent: :nullify

  TRIGGER_TYPES = %w[gps bluetooth manual qr].freeze

  validates :key, :name, :trigger_type, presence: true
  validates :key, uniqueness: { scope: :game_map_id }
  validates :trigger_type, inclusion: { in: TRIGGER_TYPES }

  scope :active, -> { where(is_active: true) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :game_map_id, :key, :name, :description, :trigger_type,
             :map_x, :map_y, :latitude, :longitude, :radius_m,
             :beacon_uuid, :beacon_major, :beacon_minor,
             :event_template_id, :sort_order, :tier_level, :config, :is_active]
    ))
  end

  def gps?
    trigger_type == "gps"
  end

  def bluetooth?
    trigger_type == "bluetooth"
  end

  def within_radius?(lat, lng)
    return false unless latitude && longitude

    GeoUtils.distance_m(lat.to_f, lng.to_f, latitude.to_f, longitude.to_f) <= radius_m
  end

  def matches_beacon?(uuid:, major: nil, minor: nil)
    return false unless bluetooth?
    return false if beacon_uuid.present? && beacon_uuid.downcase != uuid.to_s.downcase

    if beacon_major.present? && major.present? && beacon_major.to_s != major.to_s
      return false
    end
    if beacon_minor.present? && minor.present? && beacon_minor.to_s != minor.to_s
      return false
    end

    true
  end
end
