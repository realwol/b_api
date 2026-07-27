# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :openid, null: false
      t.string :nickname, default: "小仙女"
      t.string :avatar_url
      t.integer :coins, default: 1000, null: false
      t.integer :gems, default: 50, null: false
      t.integer :login_streak, default: 0, null: false
      t.datetime :last_check_in_at
      t.boolean :tutorial_completed, default: false, null: false
      t.string :auth_token

      t.timestamps
    end

    add_index :users, :openid, unique: true
    add_index :users, :auth_token, unique: true
  end
end
