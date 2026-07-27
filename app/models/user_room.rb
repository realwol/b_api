# frozen_string_literal: true

class UserRoom < ApplicationRecord
  belongs_to :user

  DEFAULT_LAYOUT = {
    "furniture" => [],
    "ornament" => [],
    "lighting" => [],
    "plant" => []
  }.freeze

  validates :room_name, presence: true

  def recalculate_stats!
    total_comfort = 10
    total_beauty = 10

    placed_ids = collect_placed_decoration_ids
    Decoration.where(id: placed_ids).find_each do |dec|
      total_comfort += dec.comfort_bonus
      total_beauty += dec.beauty_bonus
    end

    update!(comfort: total_comfort, beauty: total_beauty)
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :room_name, :wallpaper, :floor_style, :layout, :comfort, :beauty]
    ))
  end

  private

  def collect_placed_decoration_ids
    ids = []
    (layout || {}).each_value do |items|
      next unless items.is_a?(Array)

      items.each { |item| ids << item["decoration_id"] if item["decoration_id"] }
    end
    ids
  end
end
