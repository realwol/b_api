# frozen_string_literal: true

module Api
  module V1
    class DailyController < BaseController
      def status
        render json: DailyRewardService.status(current_user)
      end

      def check_in
        result = DailyRewardService.check_in!(current_user)
        render json: result
      end
    end
  end
end
