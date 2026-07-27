# frozen_string_literal: true

module Api
  module V1
    module Admin
      class MapZonesController < BaseController
        before_action :set_zone, only: [:show, :update, :destroy]

        def index
          scope = MapZone.all
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id]
          render json: { zones: scope.map(&:as_json) }
        end

        def show
          render json: { zone: @zone.as_json }
        end

        def create
          zone = MapZone.create!(zone_params)
          render json: { zone: zone.as_json }, status: :created
        end

        def update
          @zone.update!(zone_params)
          render json: { zone: @zone.as_json }
        end

        def destroy
          @zone.destroy!
          head :no_content
        end

        private

        def set_zone
          @zone = MapZone.find(params[:id])
        end

        def zone_params
          params.require(:zone).permit(
            :game_map_id, :name, :zone_type, :x_min, :y_min, :x_max, :y_max,
            :spawn_weight, :is_active, config: {}
          )
        end
      end
    end
  end
end
