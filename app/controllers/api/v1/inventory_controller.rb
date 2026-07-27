# frozen_string_literal: true

module Api
  module V1
    class InventoryController < BaseController
      def index
        render json: { inventory: InventoryService.list(current_user) }
      end

      def use
        character = current_user.characters.find(params[:character_id])
        item = Item.find(params[:item_id])
        result = InventoryService.use_item!(
          current_user,
          character,
          item,
          quantity: params[:quantity]&.to_i || 1
        )
        render json: result
      end
    end
  end
end
