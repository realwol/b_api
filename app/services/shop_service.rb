# frozen_string_literal: true

class ShopService
  class << self
    def items(item_type: nil)
      scope = Item.shop_items
      scope = scope.by_type(item_type) if item_type.present?
      scope.order(:item_type, :price_coins)
    end

    def purchase!(user, item, quantity: 1)
      raise ApiError, "数量无效" unless quantity.positive?
      raise ApiError, "商品不存在" unless item.is_shop_item?

      total_coins = item.price_coins * quantity
      total_gems = item.price_gems * quantity

      raise ApiError, "金币不足" if user.coins < total_coins
      raise ApiError, "钻石不足" if user.gems < total_gems

      EconomyService.spend_coins!(user, total_coins, source: "shop_purchase",
                                  description: "购买：#{item.name}") if total_coins.positive?
      EconomyService.spend_gems!(user, total_gems) if total_gems.positive?

      user_item = user.user_items.find_or_initialize_by(item: item)
      user_item.quantity = (user_item.quantity || 0) + quantity
      user_item.save!

      {
        user: user.reload.as_json,
        inventory_item: user.user_items.find_by(item: item).as_json
      }
    end
  end
end
