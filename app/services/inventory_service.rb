# frozen_string_literal: true

class InventoryService
  class << self
    def list(user)
      user.user_items.includes(:item).map(&:as_json)
    end

    def use_item!(user, character, item, quantity: 1)
      user_item = user.user_items.find_by(item: item)
      raise ApiError, "物品不足" unless user_item && user_item.quantity >= quantity

      action_type = action_for_item(item)
      raise ApiError, "该物品无法使用" unless action_type

      result = CareService.perform!(character, action_type: action_type, item: item)

      user_item.quantity -= quantity
      user_item.quantity.zero? ? user_item.destroy! : user_item.save!

      result.merge(inventory: list(user))
    end

    private

    def action_for_item(item)
      case item.item_type
      when "food" then "feed"
      when "outfit" then "dress"
      when "gift" then "gift"
      when "consumable" then "use_item"
      end
    end
  end
end
