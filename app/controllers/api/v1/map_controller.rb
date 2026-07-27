# frozen_string_literal: true

module Api
  module V1
    class MapController < BaseController
      def enter
        result = MapService.enter!(current_user, map_id: params[:map_id])
        render json: result
      end

      def current
        render json: MapService.current(current_user)
      end

      def move
        result = MapService.move!(
          current_user,
          map_id: params.require(:map_id),
          pos_x: params[:pos_x],
          pos_y: params[:pos_y]
        )
        render json: result
      end

      def explore
        result = MapService.explore!(current_user, map_id: params[:map_id])
        render json: result
      end

      def events
        render json: {
          events: MapEventService.list_for(current_user, status: params[:status])
        }
      end

      def start_event
        event = current_user.user_map_events.find(params[:id])
        result = MapEventService.start!(current_user, event)
        render json: result
      end

      def complete_event
        event = current_user.user_map_events.find(params[:id])
        result = MapEventService.complete!(
          current_user,
          event,
          outcome: params[:outcome] || "success",
          result_data: params[:result_data]&.to_unsafe_h || {}
        )
        render json: result
      end
    end
  end
end
