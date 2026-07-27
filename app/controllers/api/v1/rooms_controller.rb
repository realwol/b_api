# frozen_string_literal: true

module Api
  module V1
    class RoomsController < BaseController
      def show
        render json: RoomService.show(current_user)
      end

      def update
        result = RoomService.update_room!(current_user, room_params)
        render json: result
      end

      def shop
        decorations = RoomService.shop_decorations(slot_type: params[:slot_type])
        render json: { decorations: decorations.map(&:as_json) }
      end

      def purchase
        decoration = Decoration.find(params[:decoration_id])
        result = RoomService.purchase!(current_user, decoration, quantity: params[:quantity]&.to_i || 1)
        render json: result
      end

      def place
        result = RoomService.place!(
          current_user,
          decoration_id: params[:decoration_id],
          slot_type: params.require(:slot_type),
          position: params[:position]&.to_unsafe_h || {}
        )
        render json: result
      end

      def remove
        result = RoomService.remove!(
          current_user,
          slot_type: params.require(:slot_type),
          index: params.require(:index).to_i
        )
        render json: result
      end

      private

      def room_params
        params.permit(:room_name, :wallpaper, :floor_style)
      end
    end
  end
end
