# frozen_string_literal: true

class CareService
  COOLDOWN_MINUTES = 5

  ACTION_EFFECTS = {
    "feed" => { hunger: -20, mood: 5, energy: 5, affection: 2, exp: 5 },
    "play" => { mood: 15, energy: -10, hunger: 5, affection: 5, exp: 10, charm: 1 },
    "dress" => { mood: 10, charm: 2, affection: 3, exp: 5 },
    "talk" => { mood: 8, affection: 8, intelligence: 1, exp: 8 },
    "rest" => { energy: 30, mood: 5, exp: 3 },
    "gift" => { mood: 10, affection: 10, exp: 8 },
    "use_item" => { exp: 3 }
  }.freeze

  class << self
    def perform!(character, action_type:, item: nil, appearance: nil)
      validate_action!(character, action_type)

      character.apply_stat_decay!

      changes = calculate_changes(character, action_type, item)
      apply_changes!(character, changes, appearance)
      character.update!(last_cared_at: Time.current)

      log = character.care_logs.create!(
        action_type: action_type,
        item: item,
        result: changes
      )

      exp_gained = changes[:exp] || changes["exp"] || 0
      if exp_gained.positive?
        EconomyService.add_exp!(character.user, exp_gained, source: "care",
                                description: "互动：#{action_type}", character: character)
      end
      new_achievements = AchievementService.check!(character.user, :care)

      { character: character.reload.as_json, care_log: log.as_json, changes: changes,
        new_achievements: new_achievements }
    end

    private

    def validate_action!(character, action_type)
      raise ApiError, "无效的互动类型" unless CareLog::ACTION_TYPES.include?(action_type)
      raise ApiError, "角色不存在" unless character

      last_log = character.care_logs.where(action_type: action_type).order(created_at: :desc).first
      return unless last_log

      elapsed = (Time.current - last_log.created_at) / 60
      remaining = COOLDOWN_MINUTES - elapsed
      raise ApiError, "操作冷却中，请 #{remaining.ceil} 分钟后再试" if remaining > 0
    end

    def calculate_changes(character, action_type, item)
      base = ACTION_EFFECTS[action_type]&.dup || {}

      if item
        raise ApiError, "该物品无法用于此操作" unless item_usable?(action_type, item)

        stat = item.effect_type&.to_sym
        base[stat] = (base[stat] || 0) + item.effect_value if stat
        base[:exp] = (base[:exp] || 0) + 5
      end

      base
    end

    def item_usable?(action_type, item)
      case action_type
      when "feed" then item.item_type == "food"
      when "dress" then item.item_type == "outfit"
      when "gift" then item.item_type == "gift"
      when "use_item" then item.item_type == "consumable"
      else false
      end
    end

    def apply_changes!(character, changes, appearance)
      changes.each do |stat, delta|
        case stat.to_s
        when "mood", "energy", "hunger"
          current = character.send(stat)
          character.send("#{stat}=", clamp_stat(current + delta))
        when "charm", "intelligence", "affection"
          character.send("#{stat}=", [character.send(stat) + delta, 0].max)
        when "exp"
          character.add_exp!(delta)
        end
      end

      character.appearance = appearance if appearance.present?
      character.save!
    end

    def clamp_stat(value)
      [[value, 0].max, Character::STAT_CAP].min
    end
  end
end
