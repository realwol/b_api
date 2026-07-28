# frozen_string_literal: true

module Api
  module V1
    module Admin
      class MapTasksController < BaseController
        before_action :set_task, only: [:show, :update, :destroy]

        def index
          scope = MapTask.order(:sort_order, :id)
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id].present?
          render json: { tasks: scope.map(&:as_json) }
        end

        def show
          render json: { task: @task.as_json }
        end

        def create
          task = MapTask.create!(task_params)
          render json: { task: task.as_json }, status: :created
        end

        def update
          @task.update!(task_params)
          render json: { task: @task.as_json }
        end

        def destroy
          @task.destroy!
          head :no_content
        end

        private

        def set_task
          @task = MapTask.find(params[:id])
        end

        def task_params
          params.require(:task).permit(
            :game_map_id, :key, :name, :description, :task_type,
            :tier_level, :sort_order, :map_trigger_point_id, :event_template_id,
            :is_active, requirements: {}, rewards_config: {}, score_tiers: [:min_score, :max_score, { rewards_config: {} }]
          )
        end
      end
    end
  end
end
