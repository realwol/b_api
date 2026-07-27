# frozen_string_literal: true

class CreateCharacters < ActiveRecord::Migration[7.0]
  def change
    create_table :characters do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.json :appearance, default: {}, null: false
      t.integer :level, default: 1, null: false
      t.integer :exp, default: 0, null: false
      t.string :stage, default: "baby", null: false
      t.integer :charm, default: 10, null: false
      t.integer :intelligence, default: 10, null: false
      t.integer :mood, default: 80, null: false
      t.integer :energy, default: 100, null: false
      t.integer :hunger, default: 50, null: false
      t.integer :affection, default: 0, null: false
      t.boolean :is_active, default: true, null: false
      t.datetime :last_cared_at

      t.timestamps
    end
  end
end
