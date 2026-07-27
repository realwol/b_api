# frozen_string_literal: true

class CreateAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :achievements do |t|
      t.string :key, null: false
      t.string :title, null: false
      t.text :description
      t.string :category, null: false
      t.string :condition_type, null: false
      t.integer :condition_value, default: 1, null: false
      t.integer :reward_coins, default: 0, null: false
      t.integer :reward_gems, default: 0, null: false
      t.integer :reward_exp, default: 0, null: false
      t.string :icon_url

      t.timestamps
    end

    add_index :achievements, :key, unique: true
    add_index :achievements, :category
  end
end
