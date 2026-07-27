# frozen_string_literal: true

class CreateGameMaps < ActiveRecord::Migration[7.0]
  def change
    create_table :game_maps do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :background_url
      t.integer :width, default: 1000, null: false
      t.integer :height, default: 1000, null: false
      t.integer :unlock_level, default: 1, null: false
      t.integer :spawn_interval_minutes, default: 5, null: false
      t.json :config, default: {}, null: false
      t.boolean :is_active, default: true, null: false
      t.boolean :is_default, default: false, null: false

      t.timestamps
    end

    add_index :game_maps, :key, unique: true
    add_index :game_maps, :is_active
  end
end
