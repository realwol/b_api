# frozen_string_literal: true

class CreateCoinTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :coin_transactions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :amount, null: false
      t.integer :balance_after, null: false
      t.string :source, null: false
      t.string :description

      t.timestamps
    end

    add_index :coin_transactions, [:user_id, :created_at]
  end
end
