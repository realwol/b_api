# frozen_string_literal: true

module Api
  module V1
    class AuthController < ApplicationController
      include TracksPlayerActivity

      def register
        result = AuthService.register(
          account: params.require(:account),
          password: params.require(:password),
          password_confirmation: params[:password_confirmation] || params[:password],
          nickname: params[:nickname]
        )
        user = User.find_by!(auth_token: result[:token])
        PlayerActivityLogger.log_auth!(user, :auth_register, payload: { account: params[:account] }, request: request)
        render json: result, status: :created
      end

      def send_sms
        result = SmsAuthService.send_code(phone: params.require(:phone))
        render json: result
      end

      def login
        if params[:phone].present? && params[:code].present?
          result = AuthService.login_with_sms(
            phone: params.require(:phone),
            code: params.require(:code)
          )
        elsif params[:account].present?
          result = AuthService.login_with_account(
            account: params.require(:account),
            password: params.require(:password)
          )
        elsif params[:code].present?
          result = AuthService.login(
            code: params.require(:code),
            nickname: params[:nickname],
            avatar_url: params[:avatar_url]
          )
        else
          return render json: { error: "请提供手机号验证码、账号密码或微信 code" }, status: :unprocessable_entity
        end
        user = User.find_by!(auth_token: result[:token])
        PlayerActivityLogger.log_auth!(
          user, :auth_login,
          payload: {
            method: params[:phone].present? ? "sms" : (params[:account].present? ? "account" : "wechat"),
            is_new_user: result[:is_new_user],
            needs_customization: result[:needs_customization]
          },
          request: request
        )
        render json: result
      end

      def logout
        token = request.headers["Authorization"]&.remove(/^Bearer /)
        user = AuthService.find_user_by_token(token)
        return render json: { error: "请先登录" }, status: :unauthorized unless user

        PlayerActivityLogger.log_auth!(user, :auth_logout, request: request)
        AuthService.logout(user)
        render json: { ok: true }
      end

      def me
        token = request.headers["Authorization"]&.remove(/^Bearer /)
        user = AuthService.find_user_by_token(token)
        return render json: { error: "请先登录" }, status: :unauthorized unless user

        PlayerActivityLogger.log!(
          user, :api_read,
          category: "api",
          action: "auth#me",
          request_method: request.request_method,
          request_path: request.fullpath,
          payload: { endpoint: "auth/me" }
        )

        character = user.active_character
        character&.apply_stat_decay!

        render json: {
          user: user.as_json,
          character: character&.as_json,
          needs_customization: character.nil? || character.needs_customization?,
          daily_status: DailyRewardService.status(user),
          wallet: EconomyService.wallet_summary(user),
          achievement_stats: AchievementService.stats(user),
          room: user.user_room&.as_json
        }
      end
    end
  end
end
