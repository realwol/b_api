# frozen_string_literal: true

class CreateLearningCourses < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_courses do |t|
      t.references :learning_category, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.text :content, null: false
      t.integer :course_order, null: false
      t.integer :unlock_level, default: 1, null: false
      t.integer :duration_minutes, default: 5, null: false
      t.integer :reward_exp, default: 20, null: false
      t.integer :reward_coins, default: 30, null: false
      t.integer :skill_points, default: 1, null: false
      t.json :tips, default: [], null: false

      t.timestamps
    end

    add_index :learning_courses, [:learning_category_id, :course_order], unique: true, name: "index_courses_on_category_and_order"
  end
end
