# frozen_string_literal: true

module Api
  module V1
    module Admin
      class MapTriggerPointsController < BaseController
        before_action :set_point, only: [:show, :update, :destroy]

        def index
          scope = MapTriggerPoint.order(:sort_order, :id)
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id].present?
          render json: { trigger_points: scope.map(&:as_json) }
        end

        def show
          render json: { trigger_point: @point.as_json }
        end

        def create
          point = MapTriggerPoint.create!(point_params)
          render json: { trigger_point: point.as_json }, status: :created
        end

        def update
          @point.update!(point_params)
          render json: { trigger_point: @point.as_json }
        end

        def destroy
          @point.destroy!
          head :no_content
        end

        private

        def set_point
          @point = MapTriggerPoint.find(params[:id])
        end

        def point_params
          params.require(:trigger_point).permit(
            :game_map_id, :key, :name, :description, :trigger_type,
            :map_x, :map_y, :latitude, :longitude, :radius_m,
            :beacon_uuid, :beacon_major, :beacon_minor,
            :event_template_id, :sort_order, :tier_level, :is_active, config: {}
          )
        end
      end
    end
  end
end
