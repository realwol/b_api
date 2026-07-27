# frozen_string_literal: true

class StoryEpisode < ApplicationRecord
  belongs_to :story_chapter
  has_many :user_story_progresses, dependent: :destroy

  validates :title, :content, :episode_order, presence: true
  validates :episode_order, uniqueness: { scope: :story_chapter_id }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :story_chapter_id, :title, :content, :episode_order, :dialogues,
             :choices, :exp_reward, :coins_reward, :affection_reward]
    ))
  end
end
