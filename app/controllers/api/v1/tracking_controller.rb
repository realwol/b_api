# frozen_string_literal: true

module Api
  module V1
    class TrackingController < BaseController
      skip_after_action :track_player_api_request

      def create
        events = normalize_events
        logged = events.map { |event| PlayerActivityLogger.log_client!(current_user, event) }

        render json: { ok: true, count: logged.size }
      end

      private

      def normalize_events
        raw = params[:events]
        list = raw.is_a?(Array) ? raw : [params[:event].presence || params.permit!.to_h]
        list.map { |e| e.is_a?(ActionController::Parameters) ? e.to_unsafe_h : e }
      end
    end
  end
end
