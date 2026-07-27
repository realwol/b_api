# frozen_string_literal: true

module Api
  module V1
    class LearningController < BaseController
      def categories
        render json: { categories: LearningService.categories_for(current_user) }
      end

      def skills
        render json: { skills: LearningService.skills_summary(current_user) }
      end

      def skill_detail
        category = LearningCategory.find(params[:id])
        render json: LearningService.skill_detail(current_user, category)
      end

      def start
        course = LearningCourse.find(params[:id])
        result = LearningService.start_course!(current_user, course)
        render json: result
      end

      def complete
        course = LearningCourse.find(params[:id])
        result = LearningService.complete_course!(current_user, course)
        render json: result
      end
    end
  end
end
