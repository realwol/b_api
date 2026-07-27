# frozen_string_literal: true

class CreateUserItems < ActiveRecord::Migration[7.0]
  def change
    create_table :user_items do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end

    add_index :user_items, [:user_id, :item_id], unique: true
  end
end
