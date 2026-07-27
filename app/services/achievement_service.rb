# frozen_string_literal: true

class AchievementService
  class << self
    def check!(user, event_type, increment: 1)
      unlocked = []

      Achievement.where(condition_type: condition_types_for(event_type)).find_each do |achievement|
        ua = user.user_achievements.find_or_initialize_by(achievement: achievement)
        next if ua.unlocked?

        current = compute_progress(user, achievement, ua, event_type, increment)
        ua.progress = current

        if current >= achievement.condition_value
          ua.unlocked_at = Time.current
          apply_rewards!(user, achievement)
          unlocked << achievement
        end

        ua.save!
      end

      unlocked.map { |a| a.as_json.merge(unlocked: true) }
    end

    def list_for(user)
      Achievement.order(:category, :id).map do |achievement|
        ua = user.user_achievements.find_by(achievement: achievement)
        achievement.as_json.merge(
          progress: ua&.progress || 0,
          unlocked: ua&.unlocked? || false,
          unlocked_at: ua&.unlocked_at
        )
      end
    end

    def stats(user)
      total = Achievement.count
      unlocked = user.user_achievements.where.not(unlocked_at: nil).count
      { total: total, unlocked: unlocked, progress_percent: total.zero? ? 0 : (unlocked * 100 / total) }
    end

    private

    def condition_types_for(event_type)
      case event_type
      when :care then %w[care_count]
      when :story then %w[story_complete]
      when :check_in then %w[check_in_streak]
      when :user_level then %w[user_level]
      when :learning then %w[learning_complete skill_level]
      when :decoration then %w[decoration_count room_beauty]
      when :coins_earned then %w[coins_earned]
      else Achievement::CONDITION_TYPES
      end
    end

    def compute_progress(user, achievement, ua, event_type, increment)
      case achievement.condition_type
      when "care_count"
        event_type == :care ? ua.progress + increment : (ua.progress.positive? ? ua.progress : user_care_count(user))
      when "story_complete"
        user.user_story_progresses.where(status: "completed").count
      when "check_in_streak"
        user.login_streak
      when "user_level"
        user.user_level
      when "skill_level"
        user.user_skill_levels.maximum(:level) || 0
      when "learning_complete"
        event_type == :learning ? ua.progress + increment : user.user_learning_progresses.where(status: "completed").count
      when "decoration_count"
        user.user_decorations.sum(:quantity)
      when "room_beauty"
        user.user_room&.beauty || 0
      when "coins_earned"
        user.coin_transactions.where("amount > 0").sum(:amount)
      else
        ua.progress
      end
    end

    def user_care_count(user)
      CareLog.joins(:character).where(characters: { user_id: user.id }).count
    end

    def apply_rewards!(user, achievement)
      EconomyService.add_coins!(user, achievement.reward_coins, source: "achievement_reward",
                                description: "成就：#{achievement.title}") if achievement.reward_coins.positive?
      EconomyService.add_gems!(user, achievement.reward_gems) if achievement.reward_gems.positive?
      EconomyService.add_exp!(user, achievement.reward_exp, source: "achievement",
                              description: "成就：#{achievement.title}") if achievement.reward_exp.positive?
    end
  end
end
