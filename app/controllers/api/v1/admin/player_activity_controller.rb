# frozen_string_literal: true

module Api
  module V1
    module Admin
      class PlayerActivityController < BaseController
        def index
          scope = PlayerActivityLog.includes(:user, :game_map).recent
          scope = scope.where(user_id: params[:user_id]) if params[:user_id].present?
          scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id].present?
          scope = scope.where(activity_type: params[:activity_type]) if params[:activity_type].present?
          scope = scope.where("occurred_at >= ?", params[:from]) if params[:from].present?
          scope = scope.where("occurred_at <= ?", params[:to]) if params[:to].present?

          limit = params[:limit].present? ? [[params[:limit].to_i, 1].max, 200].min : 50
          logs = scope.limit(limit)

          render json: {
            logs: logs.map { |log| log.as_json.merge(
              user_nickname: log.user&.nickname,
              map_name: log.game_map&.name
            ) },
            total: logs.size
          }
        end

        def user_summary
          user = User.find(params[:user_id])
          map_id = params[:game_map_id]

          scope = user.player_activity_logs.recent
          scope = scope.where(game_map_id: map_id) if map_id.present?

          render json: {
            user: user.as_json,
            game_map: map_id.present? ? GameMap.find_by(id: map_id)&.as_json : nil,
            stats: scope.group(:activity_type).count,
            recent: scope.limit(50).map { |l| l.as_json.merge(map_name: l.game_map&.name) }
          }
        end
      end
    end
  end
end
