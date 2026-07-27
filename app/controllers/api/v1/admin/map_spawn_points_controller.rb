# frozen_string_literal: true

module Api
  module V1
    module Admin
      class MapSpawnPointsController < BaseController
        before_action :set_point, only: [:show, :update, :destroy]

        def index
          scope = MapSpawnPoint.all
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id]
          render json: { spawn_points: scope.map(&:as_json) }
        end

        def create
          point = MapSpawnPoint.create!(point_params)
          render json: { spawn_point: point.as_json }, status: :created
        end

        def update
          @point.update!(point_params)
          render json: { spawn_point: @point.as_json }
        end

        def destroy
          @point.destroy!
          head :no_content
        end

        private

        def set_point
          @point = MapSpawnPoint.find(params[:id])
        end

        def point_params
          params.require(:spawn_point).permit(
            :game_map_id, :map_zone_id, :name, :x, :y, :spawn_weight, :is_random, :is_active
          )
        end
      end
    end
  end
end
