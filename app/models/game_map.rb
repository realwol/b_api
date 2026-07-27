# frozen_string_literal: true

class GameMap < ApplicationRecord
  has_many :map_zones, dependent: :destroy
  has_many :map_spawn_points, dependent: :destroy
  has_many :event_templates, dependent: :nullify
  has_many :user_map_states, dependent: :destroy
  has_many :user_map_events, dependent: :destroy

  validates :key, :name, presence: true
  validates :key, uniqueness: true

  scope :active, -> { where(is_active: true) }

  def self.default_map
    active.find_by(is_default: true) || active.order(:id).first
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :key, :name, :description, :background_url, :width, :height,
             :unlock_level, :spawn_interval_minutes, :config, :is_active, :is_default]
    ))
  end
end
