# frozen_string_literal: true

class PlayerActivitySearchService
  class << self
    def search(params)
      scope = PlayerActivityLog.includes(:user, :game_map)
      scope = apply_filters(scope, params)

      sort = params[:sort].to_s.downcase == "asc" ? :asc : :desc
      scope = scope.order(occurred_at: sort)

      page = [params[:page].to_i, 1].max
      per_page = parse_per_page(params[:per_page] || params[:limit])
      total = scope.count
      logs = scope.offset((page - 1) * per_page).limit(per_page)

      {
        logs: logs,
        meta: {
          page: page,
          per_page: per_page,
          total: total,
          total_pages: (total.to_f / per_page).ceil,
          sort: sort.to_s
        },
        filters_applied: applied_filters(params)
      }
    end

    def apply_filters(scope, params)
      scope = filter_user(scope, params)
      scope = scope.where(game_map_id: params[:game_map_id]) if params[:game_map_id].present?
      scope = filter_categories(scope, params[:category], params[:categories])
      scope = filter_activity_types(scope, params[:activity_type], params[:activity_types])
      scope = scope.where(page: params[:page_name]) if params[:page_name].present?
      scope = scope.where(page: params[:panel]) if params[:panel].present?
      scope = scope.where("action LIKE ?", "%#{sanitize_like(params[:action])}%") if params[:action].present?
      scope = scope.where(success: ActiveModel::Type::Boolean.new.cast(params[:success])) if params.key?(:success)
      scope = filter_time_range(scope, params[:from], params[:to])
      scope
    end

    private

    def filter_user(scope, params)
      if params[:user_id].present?
        return scope.where(user_id: params[:user_id])
      end

      if params[:phone].present?
        user = User.find_by(phone: normalize_phone(params[:phone]))
        return scope.where(user_id: user.id) if user
        return scope.none
      end

      if params[:nickname].present?
        user_ids = User.where("nickname LIKE ?", "%#{sanitize_like(params[:nickname])}%").pluck(:id)
        return scope.where(user_id: user_ids)
      end

      scope
    end

    def filter_categories(scope, single, multiple)
      values = parse_list(multiple).presence || parse_list(single)
      return scope if values.empty?

      scope.where(category: values)
    end

    def filter_activity_types(scope, single, multiple)
      values = parse_list(multiple).presence || parse_list(single)
      return scope if values.empty?

      scope.where(activity_type: values)
    end

    def filter_time_range(scope, from, to)
      scope = scope.where("occurred_at >= ?", parse_time(from)) if from.present?
      scope = scope.where("occurred_at <= ?", parse_time(to)) if to.present?
      scope
    end

    def parse_list(value)
      return [] if value.blank?

      value.to_s.split(/[,|]/).map(&:strip).reject(&:blank?)
    end

    def parse_time(value)
      Time.zone.parse(value.to_s)
    rescue ArgumentError
      raise ApiError.new("时间格式无效: #{value}", status: :unprocessable_entity)
    end

    def normalize_phone(phone)
      phone.to_s.gsub(/\D/, "")
    end

    def sanitize_like(value)
      value.to_s.gsub(/[%_]/) { |m| "\\#{m}" }
    end

    def parse_per_page(value)
      per = value.to_i
      per = 50 if per <= 0
      [per, 500].min
    end

    def applied_filters(params)
      {
        user_id: params[:user_id],
        phone: params[:phone],
        nickname: params[:nickname],
        game_map_id: params[:game_map_id],
        category: params[:category] || params[:categories],
        activity_type: params[:activity_type] || params[:activity_types],
        page_name: params[:page_name] || params[:panel],
        action: params[:action],
        from: params[:from],
        to: params[:to],
        success: params[:success]
      }.compact
    end
  end
end
