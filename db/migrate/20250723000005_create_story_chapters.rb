# frozen_string_literal: true

class CreateStoryChapters < ActiveRecord::Migration[7.0]
  def change
    create_table :story_chapters do |t|
      t.string :title, null: false
      t.text :description
      t.integer :chapter_order, null: false
      t.integer :unlock_level, default: 1, null: false
      t.integer :unlock_affection, default: 0, null: false
      t.string :cover_url

      t.timestamps
    end

    add_index :story_chapters, :chapter_order, unique: true
  end
end
