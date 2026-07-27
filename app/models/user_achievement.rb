# frozen_string_literal: true

class UserAchievement < ApplicationRecord
  belongs_to :user
  belongs_to :achievement

  def unlocked?
    unlocked_at.present?
  end

  def as_json(options = {})
    {
      id: id,
      progress: progress,
      unlocked_at: unlocked_at,
      unlocked: unlocked?,
      achievement: achievement.as_json
    }
  end
end
