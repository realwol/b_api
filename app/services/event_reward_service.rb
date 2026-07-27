# frozen_string_literal: true

class EventRewardService
  class << self
    def grant!(user, rewards_config, source_description:)
      config = rewards_config.with_indifferent_access
      granted = { coins: 0, gems: 0, exp: 0, items: [], decorations: [] }

      coins = roll_amount(config[:coins_min], config[:coins_max])
      if coins.positive?
        EconomyService.add_coins!(user, coins, source: "map_event", description: source_description)
        granted[:coins] = coins
      end

      if config[:gems_chance].to_f > rand
        gems = config[:gems_amount].to_i
        EconomyService.add_gems!(user, gems) if gems.positive?
        granted[:gems] = gems
      end

      exp = roll_amount(config[:exp_min], config[:exp_max])
      if exp.positive?
        EconomyService.add_exp!(user, exp, source: "map_event", description: source_description)
        granted[:exp] = exp
      end

      (config[:items] || []).each do |item_cfg|
        next if item_cfg["chance"].to_f <= rand

        item = Item.find_by(id: item_cfg["item_id"])
        next unless item

        qty = item_cfg["quantity"].to_i
        qty = 1 if qty <= 0
        user_item = user.user_items.find_or_initialize_by(item: item)
        user_item.quantity = (user_item.quantity || 0) + qty
        user_item.save!
        granted[:items] << { item_id: item.id, name: item.name, quantity: qty }
      end

      (config[:decorations] || []).each do |dec_cfg|
        next if dec_cfg["chance"].to_f <= rand

        decoration = Decoration.find_by(id: dec_cfg["decoration_id"])
        next unless decoration

        qty = dec_cfg["quantity"].to_i
        qty = 1 if qty <= 0
        ud = user.user_decorations.find_or_initialize_by(decoration: decoration)
        ud.quantity = (ud.quantity || 0) + qty
        ud.save!
        granted[:decorations] << { decoration_id: decoration.id, name: decoration.name, quantity: qty }
      end

      granted
    end

    private

    def roll_amount(min_val, max_val)
      min_v = min_val.to_i
      max_v = max_val.to_i
      return 0 if max_v <= 0 && min_v <= 0

      max_v = min_v if max_v < min_v
      rand(min_v..max_v)
    end
  end
end
