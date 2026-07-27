# frozen_string_literal: true

class Decoration < ApplicationRecord
  has_many :user_decorations, dependent: :destroy

  SLOT_TYPES = %w[wallpaper floor furniture ornament lighting plant].freeze
  RARITIES = %w[common rare epic legendary].freeze

  validates :name, :slot_type, presence: true
  validates :slot_type, inclusion: { in: SLOT_TYPES }
  validates :rarity, inclusion: { in: RARITIES }

  scope :shop_items, -> { where(is_shop_item: true) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :description, :slot_type, :rarity, :price_coins, :price_gems,
             :comfort_bonus, :beauty_bonus, :icon_url, :sprite_url, :is_shop_item]
    ))
  end
end
