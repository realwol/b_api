# frozen_string_literal: true

class CreateSensorTriggers < ActiveRecord::Migration[7.0]
  def change
    create_table :sensor_triggers do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :sensor_type, null: false
      t.json :value_range, default: {}, null: false
      t.references :event_template, null: false, foreign_key: true
      t.references :game_map, foreign_key: true
      t.integer :priority, default: 0, null: false
      t.json :config, default: {}, null: false
      t.boolean :is_active, default: true, null: false

      t.timestamps
    end

    add_index :sensor_triggers, :key, unique: true
    add_index :sensor_triggers, :sensor_type
  end
end
