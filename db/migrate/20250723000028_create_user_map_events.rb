# frozen_string_literal: true

class CreateUserMapEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :user_map_events do |t|
      t.references :user, null: false, foreign_key: true
      t.references :event_template, null: false, foreign_key: true
      t.references :game_map, null: false, foreign_key: true
      t.references :map_zone, foreign_key: true
      t.string :status, default: "pending", null: false
      t.string :trigger_source, default: "explore", null: false
      t.integer :pos_x, null: false
      t.integer :pos_y, null: false
      t.json :event_snapshot, default: {}, null: false
      t.json :rewards_granted, default: {}, null: false
      t.json :result_data, default: {}, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.string :sensor_key

      t.timestamps
    end

    add_index :user_map_events, [:user_id, :status]
    add_index :user_map_events, [:user_id, :created_at]
  end
end
