# frozen_string_literal: true

class CreateSmsCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :sms_codes do |t|
      t.string :phone, null: false
      t.string :code, null: false
      t.datetime :expires_at, null: false
      t.timestamps
    end
    add_index :sms_codes, :phone
    add_index :sms_codes, [:phone, :code]
  end
end
