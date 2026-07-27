# frozen_string_literal: true

module Api
  module V1
    class UsersController < BaseController
      def profile
        render json: { user: current_user.as_json }
      end

      def update
        current_user.update!(user_params)
        render json: { user: current_user.as_json }
      end

      private

      def user_params
        params.permit(:nickname, :avatar_url, :tutorial_completed)
      end
    end
  end
end
