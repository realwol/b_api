# frozen_string_literal: true

module Api
  module V1
    module Admin
      class LearningCategoriesController < BaseController
        before_action :set_category, only: [:show, :update]

        def index
          render json: { categories: LearningCategory.order(:sort_order).map(&:as_json) }
        end

        def show
          render json: { category: @category.as_json, courses: @category.learning_courses.map(&:as_json) }
        end

        def update
          @category.update!(category_params)
          render json: { category: @category.as_json }
        end

        private

        def set_category
          @category = LearningCategory.find(params[:id])
        end

        def category_params
          params.require(:category).permit(
            :name, :description, :icon_url, :sort_order, :theme_color,
            milestones: [:level, :title, :description, { reward: {} }],
            display_config: {}
          )
        end
      end
    end
  end
end
