# frozen_string_literal: true

class CreateDecorations < ActiveRecord::Migration[7.0]
  def change
    create_table :decorations do |t|
      t.string :name, null: false
      t.text :description
      t.string :slot_type, null: false
      t.string :rarity, default: "common", null: false
      t.integer :price_coins, default: 0, null: false
      t.integer :price_gems, default: 0, null: false
      t.integer :comfort_bonus, default: 0, null: false
      t.integer :beauty_bonus, default: 0, null: false
      t.string :icon_url
      t.string :sprite_url
      t.boolean :is_shop_item, default: true, null: false

      t.timestamps
    end

    add_index :decorations, :slot_type
  end
end
