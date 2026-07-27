# frozen_string_literal: true

class CreateExpRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :exp_records do |t|
      t.references :user, null: false, foreign_key: true
      t.references :character, foreign_key: true
      t.integer :amount, null: false
      t.integer :total_after, null: false
      t.string :source, null: false
      t.string :description

      t.timestamps
    end

    add_index :exp_records, [:user_id, :created_at]
  end
end
