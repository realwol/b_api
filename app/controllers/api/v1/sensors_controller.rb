# frozen_string_literal: true

module Api
  module V1
    class SensorsController < BaseController
      def trigger
        result = SensorService.trigger!(
          sensor_type: params.require(:sensor_type),
          sensor_value: params.require(:sensor_value),
          user: current_user,
          sensor_key: params[:sensor_key],
          map_id: params[:map_id]
        )
        render json: result
      end
    end
  end
end
