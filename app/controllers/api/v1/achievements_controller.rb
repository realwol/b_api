# frozen_string_literal: true

module Api
  module V1
    class AchievementsController < BaseController
      def index
        render json: {
          achievements: AchievementService.list_for(current_user),
          stats: AchievementService.stats(current_user)
        }
      end
    end
  end
end
