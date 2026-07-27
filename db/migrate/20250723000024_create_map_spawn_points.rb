# frozen_string_literal: true

class CreateMapSpawnPoints < ActiveRecord::Migration[7.0]
  def change
    create_table :map_spawn_points do |t|
      t.references :game_map, null: false, foreign_key: true
      t.references :map_zone, foreign_key: true
      t.string :name
      t.integer :x, null: false
      t.integer :y, null: false
      t.integer :spawn_weight, default: 100, null: false
      t.boolean :is_random, default: true, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end
  end
end
