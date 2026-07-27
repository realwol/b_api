# frozen_string_literal: true

class UserSkillLevel < ApplicationRecord
  belongs_to :user
  belongs_to :learning_category

  POINTS_PER_LEVEL = 10

  def exp_to_next_level
    level * POINTS_PER_LEVEL
  end

  def as_json(options = {})
    super(options.merge(
      only: [:id, :learning_category_id, :level, :skill_points],
      methods: [:exp_to_next_level]
    ))
  end
end
