# frozen_string_literal: true

class CreateUserDecorations < ActiveRecord::Migration[7.0]
  def change
    create_table :user_decorations do |t|
      t.references :user, null: false, foreign_key: true
      t.references :decoration, null: false, foreign_key: true
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end

    add_index :user_decorations, [:user_id, :decoration_id], unique: true
  end
end
