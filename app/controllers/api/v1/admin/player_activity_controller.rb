# frozen_string_literal: true

module Api
  module V1
    module Admin
      class PlayerActivityController < BaseController
        def index
          render_search_result(PlayerActivitySearchService.search(search_params))
        end

        def search
          render_search_result(PlayerActivitySearchService.search(search_params))
        end

        def filters
          render json: {
            categories: PlayerActivityLog::CATEGORIES,
            activity_types: PlayerActivityLog::ACTIVITY_TYPES,
            sort_options: %w[desc asc],
            query_params: {
              user_id: "玩家 ID",
              phone: "手机号（精确）",
              nickname: "昵称（模糊）",
              game_map_id: "景区/地图 ID",
              category: "单分类：api|client|business|auth",
              categories: "多分类，逗号分隔",
              activity_type: "单操作类型",
              activity_types: "多操作类型，逗号分隔，如 page_view,ui_click,story_start",
              page_name: "页面/面板名",
              panel: "同 page_name",
              action: "动作关键字（模糊）",
              from: "开始时间 ISO8601，如 2026-07-28T00:00:00+08:00",
              to: "结束时间 ISO8601",
              success: "true/false",
              sort: "desc（默认）或 asc",
              page: "页码，默认 1",
              per_page: "每页条数，默认 50，最大 500"
            },
            examples: [
              "/api/v1/admin/player_activity/search?user_id=1&from=2026-07-28&activity_types=page_view,ui_click",
              "/api/v1/admin/player_activity/search?phone=13800138000&category=client&sort=asc",
              "/api/v1/admin/player_activity/search?activity_type=story_start&game_map_id=2&page=1&per_page=100"
            ]
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
          result = PlayerActivitySearchService.search(
            search_params.merge(user_id: user.id, sort: "asc", per_page: params[:per_page] || 1000)
          )

          render json: {
            user: user.as_json,
            flow: serialized_logs(result[:logs]),
            meta: result[:meta],
            filters_applied: result[:filters_applied]
          }
        end

        private

        def search_params
          params.permit(
            :user_id, :phone, :nickname, :game_map_id,
            :category, :categories, :activity_type, :activity_types,
            :page_name, :panel, :action, :from, :to, :success,
            :sort, :page, :per_page, :limit
          )
        end

        def render_search_result(result)
          render json: {
            logs: serialized_logs(result[:logs]),
            meta: result[:meta],
            filters_applied: result[:filters_applied]
          }
        end

        def serialized_logs(logs)
          logs.map do |log|
            log.as_json.merge(
              user_nickname: log.user&.nickname,
              user_phone: log.user&.phone,
              map_name: log.game_map&.name
            )
          end
        end
      end
    end
  end
end
