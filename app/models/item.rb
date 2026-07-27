# frozen_string_literal: true

class Item < ApplicationRecord
  has_many :user_items, dependent: :destroy
  has_many :users, through: :user_items

  ITEM_TYPES = %w[food outfit gift decoration consumable].freeze
  RARITIES = %w[common rare epic legendary].freeze
  EFFECT_TYPES = %w[mood energy hunger charm intelligence exp affection].freeze

  validates :name, :item_type, presence: true
  validates :item_type, inclusion: { in: ITEM_TYPES }
  validates :rarity, inclusion: { in: RARITIES }
  validates :effect_type, inclusion: { in: EFFECT_TYPES }, allow_nil: true

  scope :shop_items, -> { where(is_shop_item: true) }
  scope :by_type, ->(type) { where(item_type: type) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :description, :item_type, :rarity, :price_coins, :price_gems,
             :effect_type, :effect_value, :icon_url, :is_shop_item]
    ))
  end
end
