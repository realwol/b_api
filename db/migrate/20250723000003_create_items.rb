# frozen_string_literal: true

class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.string :item_type, null: false
      t.string :rarity, default: "common", null: false
      t.integer :price_coins, default: 0, null: false
      t.integer :price_gems, default: 0, null: false
      t.string :effect_type
      t.integer :effect_value, default: 0, null: false
      t.string :icon_url
      t.boolean :is_shop_item, default: true, null: false

      t.timestamps
    end

    add_index :items, :item_type
    add_index :items, :is_shop_item
  end
end
