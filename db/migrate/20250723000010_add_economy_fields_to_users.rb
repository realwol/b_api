# frozen_string_literal: true

class AddEconomyFieldsToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_level, :integer, default: 1, null: false
    add_column :users, :total_exp, :integer, default: 0, null: false
  end
end
