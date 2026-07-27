# frozen_string_literal: true

class AddAccountAuthToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account, :string
    add_column :users, :password_digest, :string
    add_index :users, :account, unique: true
  end
end
