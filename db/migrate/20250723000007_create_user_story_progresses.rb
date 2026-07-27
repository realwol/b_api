# frozen_string_literal: true

class CreateUserStoryProgresses < ActiveRecord::Migration[7.0]
  def change
    create_table :user_story_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.references :story_episode, null: false, foreign_key: true
      t.string :status, default: "locked", null: false
      t.datetime :completed_at
      t.string :choice_made

      t.timestamps
    end

    add_index :user_story_progresses, [:user_id, :story_episode_id], unique: true, name: "index_story_progress_on_user_and_episode"
  end
end
