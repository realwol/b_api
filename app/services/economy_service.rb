# frozen_string_literal: true

class EconomyService
  class << self
    def add_coins!(user, amount, source:, description: nil, game_map: nil)
      return user if amount.zero?

      user.transaction do
        user.coins += amount
        user.save!
        user.coin_transactions.create!(
          amount: amount,
          balance_after: user.coins,
          source: source,
          description: description,
          game_map_id: game_map&.id
        )
      end
      AchievementService.check!(user, :coins_earned)
      user
    end

    def spend_coins!(user, amount, source:, description: nil)
      raise ApiError, "金币不足" if user.coins < amount

      user.transaction do
        user.coins -= amount
        user.save!
        user.coin_transactions.create!(
          amount: -amount,
          balance_after: user.coins,
          source: source,
          description: description
        )
      end
      user
    end

    def add_gems!(user, amount)
      user.gems += amount
      user.save!
      user
    end

    def spend_gems!(user, amount)
      raise ApiError, "钻石不足" if user.gems < amount

      user.gems -= amount
      user.save!
      user
    end

    def add_exp!(user, amount, source:, description: nil, character: nil, game_map: nil)
      return user if amount.zero?

      user.transaction do
        user.total_exp += amount
        while user.total_exp >= user.exp_to_next_level && user.user_level < 100
          user.total_exp -= user.exp_to_next_level
          user.user_level += 1
        end
        user.save!

        user.exp_records.create!(
          character: character,
          amount: amount,
          total_after: user.total_exp,
          source: source,
          description: description,
          game_map_id: game_map&.id
        )
      end

      AchievementService.check!(user, :user_level)
      user
    end

    def wallet_summary(user)
      {
        coins: user.coins,
        gems: user.gems,
        user_level: user.user_level,
        total_exp: user.total_exp,
        exp_to_next_level: user.exp_to_next_level,
        recent_coins: user.coin_transactions.order(created_at: :desc).limit(10).map(&:as_json),
        recent_exp: user.exp_records.order(created_at: :desc).limit(10).map(&:as_json)
      }
    end
  end
end
