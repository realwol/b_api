# frozen_string_literal: true

class DailyRewardService
  # 7天循环签到奖励
  REWARDS = [
    { coins: 100, gems: 0 },
    { coins: 150, gems: 0 },
    { coins: 200, gems: 5 },
    { coins: 250, gems: 0 },
    { coins: 300, gems: 10 },
    { coins: 400, gems: 0 },
    { coins: 500, gems: 20 }
  ].freeze

  class << self
    def status(user)
      {
        checked_in_today: user.checked_in_today?,
        login_streak: user.login_streak,
        today_reward: reward_for_day(next_streak_day(user)),
        weekly_rewards: REWARDS.map.with_index(1) { |r, i| r.merge(day: i) }
      }
    end

    def check_in!(user)
      raise ApiError, "今日已签到" if user.checked_in_today?

      streak_day = next_streak_day(user)
      reward = reward_for_day(streak_day)

      user.transaction do
        EconomyService.add_coins!(user, reward[:coins], source: "daily_check_in",
                                  description: "第#{streak_day}天签到")
        EconomyService.add_gems!(user, reward[:gems]) if reward[:gems].positive?
        user.login_streak = streak_day
        user.last_check_in_at = Time.current
        user.save!

        check_in = user.daily_check_ins.create!(
          check_in_date: Date.current,
          reward_coins: reward[:coins],
          reward_gems: reward[:gems],
          streak_day: streak_day
        )

        new_achievements = AchievementService.check!(user, :check_in)

        { user: user.reload.as_json, check_in: check_in.as_json, reward: reward,
          new_achievements: new_achievements }
      end
    end

    private

    def next_streak_day(user)
      if user.last_check_in_at&.to_date == Date.yesterday
        [user.login_streak + 1, 7].min
      else
        1
      end
    end

    def reward_for_day(day)
      REWARDS[[day - 1, REWARDS.length - 1].min]
    end
  end
end
