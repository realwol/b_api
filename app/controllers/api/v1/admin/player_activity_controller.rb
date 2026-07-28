# frozen_string_literal: true

module Api
  module V1
    module Admin
      class PlayerActivityController < BaseController
        def index
          render json: {
            logs: serialized_logs(filtered_scope.limit(parsed_limit)),
            total: filtered_scope.count
          }
        end

        def user_summary
          user = User.find(params[:user_id])
          scope = user.player_activity_logs.recent
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id].present?

          render json: {
            user: user.as_json,
            game_map: params[:game_map_id].present? ? GameMap.find_by(id: params[:game_map_id])&.as_json : nil,
            stats_by_type: scope.group(:activity_type).count,
            stats_by_category: scope.group(:category).count,
            stats_by_page: scope.where.not(page: [nil, ""]).group(:page).count,
            recent: serialized_logs(scope.limit(100))
          }
        end

        def user_flow
          user = User.find(params[:user_id])
          scope = user.player_activity_logs.order(occurred_at: :asc)
          scope = apply_filters(scope)

          logs = scope.limit(parsed_limit(max: 1000))
          render json: {
            user: user.as_json,
            flow: serialized_logs(logs),
            total: scope.count
          }
        end

        private

        def filtered_scope
          apply_filters(PlayerActivityLog.includes(:user, :game_map).recent)
        end

        def apply_filters(scope)
          scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id].present?
          scope = scope.where(activity_type: params[:activity_type]) if params[:activity_type].present?
          scope = scope.where(category: params[:category]) if params[:category].present?
          scope = scope.where(page: params[:page]) if params[:page].present?
          scope = scope.where("action LIKE ?", "%#{params[:action]}%") if params[:action].present?
          scope = scope.where("occurred_at >= ?", params[:from]) if params[:from].present?
          scope = scope.where("occurred_at <= ?", params[:to]) if params[:to].present?
          scope
        end

        def parsed_limit(max: 200)
          return 50 if params[:limit].blank?

          [[params[:limit].to_i, 1].max, max].min
        end

        def serialized_logs(logs)
          logs.map do |log|
            log.as_json.merge(
              user_nickname: log.user&.nickname,
              map_name: log.game_map&.name
            )
          end
        end
      end
    end
  end
end
