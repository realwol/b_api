# frozen_string_literal: true

class CreateCareLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :care_logs do |t|
      t.references :character, null: false, foreign_key: true
      t.string :action_type, null: false
      t.references :item, foreign_key: true
      t.json :result, default: {}, null: false

      t.timestamps
    end

    add_index :care_logs, [:character_id, :created_at]
  end
end
