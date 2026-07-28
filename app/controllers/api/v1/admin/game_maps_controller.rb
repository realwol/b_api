# frozen_string_literal: true

module Api
  module V1
    module Admin
      class GameMapsController < BaseController
        before_action :set_map, only: [:show, :update, :destroy, :upload_route_image]

        def index
          render json: { maps: GameMap.order(:id).map(&:as_json) }
        end

        def show
          render json: {
            map: @map.as_json,
            zones: @map.map_zones.map(&:as_json),
            spawn_points: @map.map_spawn_points.map(&:as_json),
            trigger_points: @map.map_trigger_points.map(&:as_json),
            tasks: @map.map_tasks.map(&:as_json)
          }
        end

        def create
          map = GameMap.create!(map_params)
          render json: { map: map.as_json }, status: :created
        end

        def update
          @map.update!(map_params)
          render json: { map: @map.as_json }
        end

        def upload_route_image
          file = params[:file]
          raise ApiError.new("请上传图片文件", status: :unprocessable_entity) unless file.respond_to?(:read)

          dir = Rails.root.join("public", "maps", "scenic")
          FileUtils.mkdir_p(dir)
          filename = "#{@map.key}_route#{File.extname(file.original_filename.to_s.presence || '.png')}"
          path = dir.join(filename)
          File.binwrite(path, file.read)

          url = "/maps/scenic/#{filename}"
          @map.update!(route_image_url: url, background_url: url)
          render json: { map: @map.as_json, route_image_url: url }
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
            :key, :name, :description, :background_url, :route_image_url, :width, :height,
            :unlock_level, :spawn_interval_minutes, :is_active, :is_default, :map_type,
            :center_lat, :center_lng, :default_zoom, :address, :city, :region,
            config: {}, bounds_geo: {}, route_polyline: {}
          )
        end
      end
    end
  end
end
