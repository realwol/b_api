# frozen_string_literal: true

class UserStoryProgress < ApplicationRecord
  belongs_to :user
  belongs_to :story_episode

  STATUSES = %w[locked available in_progress completed].freeze

  validates :status, inclusion: { in: STATUSES }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :story_episode_id, :status, :completed_at, :choice_made]
    ))
  end
end
