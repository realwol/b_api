# frozen_string_literal: true

class CreateDailyCheckIns < ActiveRecord::Migration[7.0]
  def change
    create_table :daily_check_ins do |t|
      t.references :user, null: false, foreign_key: true
      t.date :check_in_date, null: false
      t.integer :reward_coins, default: 0, null: false
      t.integer :reward_gems, default: 0, null: false
      t.integer :streak_day, default: 1, null: false

      t.timestamps
    end

    add_index :daily_check_ins, [:user_id, :check_in_date], unique: true
  end
end
