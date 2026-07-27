# frozen_string_literal: true

module Api
  module V1
    module Admin
      class GameMapsController < BaseController
        before_action :set_map, only: [:show, :update, :destroy]

        def index
          render json: { maps: GameMap.order(:id).map(&:as_json) }
        end

        def show
          render json: { map: @map.as_json, zones: @map.map_zones.map(&:as_json),
                         spawn_points: @map.map_spawn_points.map(&:as_json) }
        end

        def create
          map = GameMap.create!(map_params)
          render json: { map: map.as_json }, status: :created
        end

        def update
          @map.update!(map_params)
          render json: { map: @map.as_json }
        end

        def destroy
          @map.destroy!
          head :no_content
        end

        private

        def set_map
          @map = GameMap.find(params[:id])
        end

        def map_params
          params.require(:map).permit(
            :key, :name, :description, :background_url, :width, :height,
            :unlock_level, :spawn_interval_minutes, :is_active, :is_default, config: {}
          )
        end
      end
    end
  end
end
