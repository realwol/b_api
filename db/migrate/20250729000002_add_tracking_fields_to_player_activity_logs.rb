# frozen_string_literal: true

class AddTrackingFieldsToPlayerActivityLogs < ActiveRecord::Migration[7.0]
  def change
    change_table :player_activity_logs, bulk: true do |t|
      t.string :category, default: "business", null: false
      t.string :action
      t.string :page
      t.string :session_id
      t.string :request_method
      t.string :request_path
      t.integer :status_code
      t.boolean :success, default: true, null: false
    end

    add_index :player_activity_logs, :category
    add_index :player_activity_logs, :session_id
    add_index :player_activity_logs, [:user_id, :occurred_at]
    add_index :player_activity_logs, :action
  end
end
