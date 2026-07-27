# frozen_string_literal: true

class RoomService
  class << self
    def setup_room!(user)
      user.create_user_room!(
        room_name: "#{user.nickname}的小窝",
        layout: UserRoom::DEFAULT_LAYOUT.dup
      )
    end

    def show(user)
      room = user.user_room || setup_room!(user)
      room.as_json.merge(
        owned_decorations: user.user_decorations.includes(:decoration).map(&:as_json)
      )
    end

    def shop_decorations(slot_type: nil)
      scope = Decoration.shop_items
      scope = scope.where(slot_type: slot_type) if slot_type.present?
      scope.order(:slot_type, :price_coins)
    end

    def purchase!(user, decoration, quantity: 1)
      raise ApiError, "数量无效" unless quantity.positive?

      total_coins = decoration.price_coins * quantity
      total_gems = decoration.price_gems * quantity

      EconomyService.spend_coins!(user, total_coins, source: "decoration_purchase",
                                  description: "购买装饰：#{decoration.name}") if total_coins.positive?
      EconomyService.spend_gems!(user, total_gems) if total_gems.positive?

      ud = user.user_decorations.find_or_initialize_by(decoration: decoration)
      ud.quantity = (ud.quantity || 0) + quantity
      ud.save!

      AchievementService.check!(user, :decoration)

      { user: user.reload.as_json, decoration: ud.as_json }
    end

    def place!(user, decoration_id:, slot_type:, position: {})
      room = user.user_room || setup_room!(user)
      decoration = Decoration.find(decoration_id)
      ud = user.user_decorations.find_by(decoration: decoration)
      raise ApiError, "未拥有该装饰" unless ud&.quantity&.positive?

      layout = room.layout.deep_dup
      layout[slot_type] ||= []

      already_placed = count_placed(room.layout, decoration_id)
      raise ApiError, "装饰数量不足" if already_placed >= ud.quantity

      layout[slot_type] << {
        "decoration_id" => decoration.id,
        "name" => decoration.name,
        "position" => position,
        "placed_at" => Time.current.iso8601
      }

      if decoration.slot_type.in?(%w[wallpaper floor])
        room.update!(decoration.slot_type => decoration.name.parameterize.underscore)
      else
        room.update!(layout: layout)
      end

      room.recalculate_stats!
      AchievementService.check!(user, :decoration)

      { room: room.reload.as_json }
    end

    def remove!(user, slot_type:, index:)
      room = user.user_room
      raise ApiError, "房间不存在" unless room

      layout = room.layout.deep_dup
      items = layout[slot_type] || []
      raise ApiError, "装饰不存在" if index.negative? || index >= items.length

      items.delete_at(index)
      layout[slot_type] = items
      room.update!(layout: layout)
      room.recalculate_stats!

      { room: room.reload.as_json }
    end

    def update_room!(user, params)
      room = user.user_room || setup_room!(user)
      room.update!(params.slice(:room_name, :wallpaper, :floor_style))
      { room: room.as_json }
    end

    private

    def count_placed(layout, decoration_id)
      count = 0
      (layout || {}).each_value do |items|
        next unless items.is_a?(Array)

        items.each { |i| count += 1 if i["decoration_id"] == decoration_id }
      end
      count
    end
  end
end
