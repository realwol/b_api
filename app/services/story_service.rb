# frozen_string_literal: true

class StoryService
  class << self
    def initialize_progress!(user)
      first_episode = StoryEpisode.joins(:story_chapter)
                                  .order("story_chapters.chapter_order", :episode_order)
                                  .first
      return unless first_episode

      progress = user.user_story_progresses.find_or_initialize_by(story_episode: first_episode)
      progress.status = "available" if progress.status == "locked"
      progress.save!
    end

    def chapters_for(user)
      character = user.active_character
      StoryChapter.order(:chapter_order).map do |chapter|
        chapter_json = chapter.as_json
        chapter_json["episodes"] = chapter.story_episodes.map do |episode|
          episode_json = episode.as_json
          episode_json["progress"] = progress_for(user, episode)
          episode_json["unlocked"] = episode_unlocked?(character, chapter, episode, user)
          episode_json
        end
        chapter_json["unlocked"] = chapter_unlocked?(character, chapter)
        chapter_json
      end
    end

    def start_episode!(user, episode)
      character = user.active_character
      chapter = episode.story_chapter
      raise ApiError, "章节未解锁" unless chapter_unlocked?(character, chapter)
      raise ApiError, "剧情未解锁" unless episode_unlocked?(character, chapter, episode, user)

      progress = find_or_create_progress(user, episode)
      raise ApiError, "该剧情已完成" if progress.status == "completed"

      progress.update!(status: "in_progress")
      { episode: episode.as_json, progress: progress.as_json }
    end

    def complete_episode!(user, episode, choice: nil)
      progress = user.user_story_progresses.find_by(story_episode: episode)
      raise ApiError, "请先开始剧情" unless progress&.status == "in_progress"

      character = user.active_character
      rewards = apply_rewards!(user, character, episode)

      progress.update!(
        status: "completed",
        completed_at: Time.current,
        choice_made: choice
      )

      unlock_next_episode!(user, episode)

      {
        progress: progress.as_json,
        rewards: rewards,
        character: character.reload.as_json
      }
    end

    private

    def progress_for(user, episode)
      user.user_story_progresses.find_by(story_episode: episode)&.as_json ||
        { status: "locked" }
    end

    def chapter_unlocked?(character, chapter)
      return false unless character

      character.level >= chapter.unlock_level &&
        character.affection >= chapter.unlock_affection
    end

    def episode_unlocked?(character, chapter, episode, user)
      return false unless chapter_unlocked?(character, chapter)

      first_in_chapter = chapter.story_episodes.order(:episode_order).first
      return true if episode.id == first_in_chapter&.id

      prev_episode = chapter.story_episodes
                            .where("episode_order < ?", episode.episode_order)
                            .order(episode_order: :desc)
                            .first
      return false unless prev_episode

      user.user_story_progresses.find_by(story_episode: prev_episode)&.status == "completed"
    end

    def find_or_create_progress(user, episode)
      user.user_story_progresses.find_or_create_by!(story_episode: episode) do |p|
        p.status = "available"
      end
    end

    def apply_rewards!(user, character, episode)
      character.add_exp!(episode.exp_reward)
      character.affection += episode.affection_reward
      character.save!

      EconomyService.add_coins!(user, episode.coins_reward, source: "story_reward",
                                description: "剧情：#{episode.title}")
      EconomyService.add_exp!(user, episode.exp_reward, source: "story",
                              description: "剧情：#{episode.title}", character: character)
      AchievementService.check!(user, :story)

      {
        exp: episode.exp_reward,
        coins: episode.coins_reward,
        affection: episode.affection_reward
      }
    end

    def unlock_next_episode!(user, episode)
      next_episode = StoryEpisode
                       .where(story_chapter_id: episode.story_chapter_id)
                       .where("episode_order > ?", episode.episode_order)
                       .order(:episode_order)
                       .first

      if next_episode
        progress = user.user_story_progresses.find_or_initialize_by(story_episode: next_episode)
        progress.status = "available" if progress.status == "locked"
        progress.save!
        return
      end

      next_chapter = StoryChapter.where("chapter_order > ?", episode.story_chapter.chapter_order)
                                 .order(:chapter_order)
                                 .first
      return unless next_chapter

      first_episode = next_chapter.story_episodes.order(:episode_order).first
      return unless first_episode

      progress = user.user_story_progresses.find_or_initialize_by(story_episode: first_episode)
      progress.status = "available" if progress.status == "locked"
      progress.save!
    end
  end
end
