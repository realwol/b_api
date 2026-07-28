# frozen_string_literal: true

class AddScenicMapSystem < ActiveRecord::Migration[7.0]
  def change
    change_table :game_maps, bulk: true do |t|
      t.string :map_type, default: "virtual", null: false
      t.decimal :center_lat, precision: 10, scale: 7
      t.decimal :center_lng, precision: 10, scale: 7
      t.integer :default_zoom, default: 16
      t.json :bounds_geo, default: {}
      t.json :route_polyline, default: []
      t.string :route_image_url
      t.string :address
      t.string :city
      t.string :region
    end
    add_index :game_maps, :map_type

    create_table :map_trigger_points do |t|
      t.references :game_map, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :trigger_type, null: false, default: "gps"
      t.integer :map_x, default: 0, null: false
      t.integer :map_y, default: 0, null: false
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.integer :radius_m, default: 50, null: false
      t.string :beacon_uuid
      t.string :beacon_major
      t.string :beacon_minor
      t.integer :event_template_id
      t.integer :sort_order, default: 0, null: false
      t.integer :tier_level, default: 1, null: false
      t.json :config, default: {}
      t.boolean :is_active, default: true, null: false
      t.timestamps
    end
    add_index :map_trigger_points, [:game_map_id, :key], unique: true
    add_index :map_trigger_points, :trigger_type

    create_table :map_tasks do |t|
      t.references :game_map, null: false, foreign_key: true
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.string :task_type, null: false, default: "checkpoint"
      t.integer :tier_level, default: 1, null: false
      t.integer :sort_order, default: 0, null: false
      t.integer :map_trigger_point_id
      t.integer :event_template_id
      t.json :requirements, default: {}
      t.json :score_tiers, default: []
      t.json :rewards_config, default: {}
      t.boolean :is_active, default: true, null: false
      t.timestamps
    end
    add_index :map_tasks, [:game_map_id, :key], unique: true

    create_table :user_map_task_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game_map, null: false, foreign_key: true
      t.references :map_task, null: false, foreign_key: true
      t.string :status, default: "locked", null: false
      t.integer :best_score, default: 0, null: false
      t.json :progress_data, default: {}
      t.datetime :completed_at
      t.timestamps
    end
    add_index :user_map_task_progresses, [:user_id, :game_map_id, :map_task_id], unique: true, name: "idx_user_map_task_progress"

    create_table :player_activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :game_map_id
      t.string :activity_type, null: false
      t.string :ref_type
      t.string :ref_id
      t.json :payload, default: {}
      t.datetime :occurred_at, null: false
      t.timestamps
    end
    add_index :player_activity_logs, [:user_id, :game_map_id, :occurred_at]
    add_index :player_activity_logs, [:activity_type, :occurred_at]
    add_index :player_activity_logs, :game_map_id

    add_reference :coin_transactions, :game_map, foreign_key: true
    add_reference :exp_records, :game_map, foreign_key: true
  end
end
