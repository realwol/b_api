# frozen_string_literal: true

class LearningCourse < ApplicationRecord
  belongs_to :learning_category
  has_many :user_learning_progresses, dependent: :destroy

  validates :title, :content, :course_order, presence: true

  def as_json(options = {})
    super(options.merge(
      only: [:id, :learning_category_id, :title, :description, :content, :course_order,
             :unlock_level, :duration_minutes, :reward_exp, :reward_coins, :skill_points, :tips]
    ))
  end
end
