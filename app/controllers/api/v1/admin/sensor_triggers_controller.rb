# frozen_string_literal: true

module Api
  module V1
    module Admin
      class SensorTriggersController < BaseController
        before_action :set_trigger, only: [:show, :update, :destroy]

        def index
          render json: { sensor_triggers: SensorTrigger.order(:priority).map(&:as_json) }
        end

        def show
          render json: { sensor_trigger: @trigger.as_json }
        end

        def create
          trigger = SensorTrigger.create!(trigger_params)
          render json: { sensor_trigger: trigger.as_json }, status: :created
        end

        def update
          @trigger.update!(trigger_params)
          render json: { sensor_trigger: @trigger.as_json }
        end

        def destroy
          @trigger.destroy!
          head :no_content
        end

        # 硬件/管理后台触发传感器事件
        def fire
          user = User.find(params.require(:user_id))
          result = SensorService.trigger!(
            sensor_type: params.require(:sensor_type),
            sensor_value: params.require(:sensor_value),
            user: user,
            sensor_key: params[:sensor_key],
            map_id: params[:map_id]
          )
          render json: result
        end

        private

        def set_trigger
          @trigger = SensorTrigger.find(params[:id])
        end

        def trigger_params
          params.require(:sensor_trigger).permit(
            :key, :name, :description, :sensor_type, :event_template_id,
            :game_map_id, :priority, :is_active, value_range: {}, config: {}
          )
        end
      end
    end
  end
end
