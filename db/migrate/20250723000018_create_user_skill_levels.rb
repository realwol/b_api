# frozen_string_literal: true

class CreateUserSkillLevels < ActiveRecord::Migration[7.0]
  def change
    create_table :user_skill_levels do |t|
      t.references :user, null: false, foreign_key: true
      t.references :learning_category, null: false, foreign_key: true
      t.integer :level, default: 0, null: false
      t.integer :skill_points, default: 0, null: false

      t.timestamps
    end

    add_index :user_skill_levels, [:user_id, :learning_category_id], unique: true, name: "index_skill_levels_on_user_and_category"
  end
end
