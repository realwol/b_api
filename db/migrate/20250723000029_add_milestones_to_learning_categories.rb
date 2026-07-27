# frozen_string_literal: true

class AddMilestonesToLearningCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :learning_categories, :milestones, :json, default: [], null: false
    add_column :learning_categories, :display_config, :json, default: {}, null: false
  end
end
