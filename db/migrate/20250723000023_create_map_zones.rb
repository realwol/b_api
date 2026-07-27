# frozen_string_literal: true

class CreateMapZones < ActiveRecord::Migration[7.0]
  def change
    create_table :map_zones do |t|
      t.references :game_map, null: false, foreign_key: true
      t.string :name, null: false
      t.string :zone_type, default: "normal", null: false
      t.integer :x_min, default: 0, null: false
      t.integer :y_min, default: 0, null: false
      t.integer :x_max, default: 1000, null: false
      t.integer :y_max, default: 1000, null: false
      t.integer :spawn_weight, default: 100, null: false
      t.json :config, default: {}, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end
  end
end
