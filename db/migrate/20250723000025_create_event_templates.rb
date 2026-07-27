# frozen_string_literal: true

class CreateEventTemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :event_templates do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :event_type, null: false
      t.integer :difficulty, default: 1, null: false
      t.references :game_map, foreign_key: true
      t.references :map_zone, foreign_key: true
      t.references :learning_category, foreign_key: true
      t.integer :min_user_level, default: 1, null: false
      t.integer :max_user_level, default: 999, null: false
      t.integer :trigger_weight, default: 100, null: false
      t.integer :cooldown_minutes, default: 0, null: false
      t.json :content, default: {}, null: false
      t.json :rewards_config, default: {}, null: false
      t.json :trigger_conditions, default: {}, null: false
      t.boolean :sensor_triggerable, default: false, null: false
      t.boolean :is_active, default: true, null: false
      t.integer :sort_order, default: 0, null: false

      t.timestamps
    end

    add_index :event_templates, :key, unique: true
    add_index :event_templates, :event_type
    add_index :event_templates, :is_active
  end
end
