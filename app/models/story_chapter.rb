# frozen_string_literal: true

class StoryChapter < ApplicationRecord
  has_many :story_episodes, -> { order(:episode_order) }, dependent: :destroy

  validates :title, :chapter_order, presence: true
  validates :chapter_order, uniqueness: true

  def as_json(options = {})
    super(options.merge(
      only: [:id, :title, :description, :chapter_order, :unlock_level, :unlock_affection, :cover_url]
    ))
  end
end
