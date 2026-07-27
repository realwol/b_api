# frozen_string_literal: true

class MapSpawnPoint < ApplicationRecord
  belongs_to :game_map
  belongs_to :map_zone, optional: true

  scope :active, -> { where(is_active: true) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :game_map_id, :map_zone_id, :name, :x, :y, :spawn_weight, :is_random, :is_active]
    ))
  end
end
