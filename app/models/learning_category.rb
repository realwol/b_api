# frozen_string_literal: true

class LearningCategory < ApplicationRecord
  has_many :learning_courses, -> { order(:course_order) }, dependent: :destroy
  has_many :user_skill_levels, dependent: :destroy

  validates :name, presence: true

  def as_json(options = {})
    super(options.merge(
      only: [:id, :name, :description, :icon_url, :sort_order, :theme_color, :milestones, :display_config]
    ))
  end
end
