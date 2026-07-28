# frozen_string_literal: true

class UserMapTaskProgress < ApplicationRecord
  belongs_to :user
  belongs_to :game_map
  belongs_to :map_task

  STATUSES = %w[locked available in_progress completed].freeze

  validates :status, inclusion: { in: STATUSES }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :user_id, :game_map_id, :map_task_id, :status,
             :best_score, :progress_data, :completed_at]
    ))
  end
end
