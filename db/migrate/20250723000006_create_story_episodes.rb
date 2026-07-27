# frozen_string_literal: true

class CreateStoryEpisodes < ActiveRecord::Migration[7.0]
  def change
    create_table :story_episodes do |t|
      t.references :story_chapter, null: false, foreign_key: true
      t.string :title, null: false
      t.text :content, null: false
      t.integer :episode_order, null: false
      t.json :dialogues, default: [], null: false
      t.json :choices, default: [], null: false
      t.integer :exp_reward, default: 10, null: false
      t.integer :coins_reward, default: 50, null: false
      t.integer :affection_reward, default: 5, null: false

      t.timestamps
    end

    add_index :story_episodes, [:story_chapter_id, :episode_order], unique: true, name: "index_episodes_on_chapter_and_order"
  end
end
