# frozen_string_literal: true

class CreateLearningCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :learning_categories do |t|
      t.string :name, null: false
      t.text :description
      t.string :icon_url
      t.integer :sort_order, default: 0, null: false
      t.string :theme_color, default: "#FFB6C1"

      t.timestamps
    end

    add_index :learning_categories, :sort_order
  end
end
