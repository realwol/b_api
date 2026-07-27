# frozen_string_literal: true

module Api
  module V1
    class EconomyController < BaseController
      def wallet
        render json: EconomyService.wallet_summary(current_user)
      end
    end
  end
end
