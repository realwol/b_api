# frozen_string_literal: true

class CreateUserAchievements < ActiveRecord::Migration[7.0]
  def change
    create_table :user_achievements do |t|
      t.references :user, null: false, foreign_key: true
      t.references :achievement, null: false, foreign_key: true
      t.integer :progress, default: 0, null: false
      t.datetime :unlocked_at

      t.timestamps
    end

    add_index :user_achievements, [:user_id, :achievement_id], unique: true
  end
end
