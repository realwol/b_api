# frozen_string_literal: true

class CreateUserLearningProgresses < ActiveRecord::Migration[7.0]
  def change
    create_table :user_learning_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :learning_course, null: false, foreign_key: true
      t.string :status, default: "locked", null: false
      t.integer :skill_level, default: 0, null: false
      t.datetime :completed_at

      t.timestamps
    end

    add_index :user_learning_progresses, [:user_id, :learning_course_id], unique: true, name: "index_learning_progress_on_user_and_course"
  end
end
