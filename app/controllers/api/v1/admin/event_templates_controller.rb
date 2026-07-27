# frozen_string_literal: true

module Api
  module V1
    module Admin
      class EventTemplatesController < BaseController
        before_action :set_template, only: [:show, :update, :destroy]

        def index
          scope = EventTemplate.order(:sort_order, :id)
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id]
          scope = scope.where(event_type: params[:event_type]) if params[:event_type]
          render json: { event_templates: scope.map(&:as_json) }
        end

        def show
          render json: { event_template: @template.as_json }
        end

        def create
          template = EventTemplate.create!(template_params)
          render json: { event_template: template.as_json }, status: :created
        end

        def update
          @template.update!(template_params)
          render json: { event_template: @template.as_json }
        end

        def destroy
          @template.destroy!
          head :no_content
        end

        private

        def set_template
          @template = EventTemplate.find(params[:id])
        end

        def template_params
          params.require(:event_template).permit(
            :key, :name, :description, :event_type, :difficulty,
            :game_map_id, :map_zone_id, :learning_category_id,
            :min_user_level, :max_user_level, :trigger_weight, :cooldown_minutes,
            :sensor_triggerable, :is_active, :sort_order,
            content: {}, rewards_config: {}, trigger_conditions: {}
          )
        end
      end
    end
  end
end
