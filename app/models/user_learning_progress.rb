# frozen_string_literal: true

class UserLearningProgress < ApplicationRecord
  belongs_to :user
  belongs_to :learning_course

  STATUSES = %w[locked available in_progress completed].freeze

  validates :status, inclusion: { in: STATUSES }

  def as_json(options = {})
    super(options.merge(only: [:id, :learning_course_id, :status, :skill_level, :completed_at]))
  end
end
