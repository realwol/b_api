# frozen_string_literal: true

class CreateUserRooms < ActiveRecord::Migration[7.0]
  def change
    create_table :user_rooms do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :room_name, default: "我的小窝", null: false
      t.string :wallpaper, default: "pink_wall", null: false
      t.string :floor_style, default: "wood_light", null: false
      t.json :layout, default: {}, null: false
      t.integer :comfort, default: 10, null: false
      t.integer :beauty, default: 10, null: false

      t.timestamps
    end
  end
end
