# frozen_string_literal: true

module Api
  module V1
    class ShopController < BaseController
      def index
        items = ShopService.items(item_type: params[:item_type])
        render json: { items: items.map(&:as_json) }
      end

      def purchase
        item = Item.find(params[:item_id])
        result = ShopService.purchase!(current_user, item, quantity: params[:quantity]&.to_i || 1)
        render json: result
      end
    end
  end
end
