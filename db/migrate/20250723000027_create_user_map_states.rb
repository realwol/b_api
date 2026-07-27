# frozen_string_literal: true

class CreateUserMapStates < ActiveRecord::Migration[7.0]
  def change
    create_table :user_map_states do |t|
      t.references :user, null: false, foreign_key: true
      t.references :game_map, null: false, foreign_key: true
      t.integer :pos_x, default: 500, null: false
      t.integer :pos_y, default: 500, null: false
      t.datetime :entered_at
      t.datetime :last_explored_at
      t.integer :explore_count, default: 0, null: false

      t.timestamps
    end

    add_index :user_map_states, [:user_id, :game_map_id], unique: true
  end
end
