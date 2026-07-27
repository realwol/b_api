# frozen_string_literal: true

require "net/http"

module AuthService
  class << self
    # 小程序登录：开发环境用 code 模拟 openid，生产环境对接微信 code2session
    def login(code:, nickname: nil, avatar_url: nil)
      openid = resolve_openid(code)

      user = User.find_or_initialize_by(openid: openid)
      user.nickname = nickname if nickname.present?
      user.avatar_url = avatar_url if avatar_url.present?
      user.regenerate_auth_token! if user.persisted?
      user.save!

      bootstrap_user!(user, create_character: false)

      auth_payload(user)
    end

    def register(account:, password:, password_confirmation:, nickname: nil)
      normalized = normalize_account(account)
      validate_account!(normalized)
      validate_password!(password, password_confirmation)

      if User.exists?(account: normalized)
        raise ApiError.new("账号已被注册", status: :unprocessable_entity)
      end

      user = User.new(
        account: normalized,
        openid: synthetic_openid(normalized),
        nickname: nickname.presence || normalized,
        password: password
      )
      user.save!

      bootstrap_user!(user, create_character: false)

      auth_payload(user)
    end

    def login_with_account(account:, password:)
      normalized = normalize_account(account)
      user = User.find_by(account: normalized)
      unless user&.authenticate(password)
        raise ApiError.new("账号或密码错误", status: :unauthorized)
      end

      user.regenerate_auth_token!
      auth_payload(user)
    end

    def login_with_sms(phone:, code:)
      normalized = SmsAuthService.verify!(phone: phone, code: code)
      user = User.find_by(phone: normalized)
      is_new = user.nil?
      unless user
        user = User.create!(
          phone: normalized,
          openid: synthetic_openid("phone_#{normalized}"),
          nickname: "旅人#{normalized[-4..]}"
        )
        bootstrap_user!(user, create_character: false)
      else
        bootstrap_user!(user, create_character: false)
      end

      user.regenerate_auth_token!
      auth_payload(user, is_new: is_new)
    end

    def logout(user)
      user.regenerate_auth_token!
      true
    end

    def find_user_by_token(token)
      return nil if token.blank?

      User.find_by(auth_token: token)
    end

    private

    def normalize_account(account)
      account.to_s.strip.downcase
    end

    def validate_account!(account)
      raise ApiError.new("账号不能为空", status: :unprocessable_entity) if account.blank?
      raise ApiError.new("账号至少3个字符", status: :unprocessable_entity) if account.length < 3
      raise ApiError.new("账号格式不正确", status: :unprocessable_entity) unless account.match?(/\A[a-z0-9_\.\@]+\z/)
    end

    def validate_password!(password, password_confirmation)
      raise ApiError.new("密码不能为空", status: :unprocessable_entity) if password.blank?
      raise ApiError.new("密码至少6位", status: :unprocessable_entity) if password.length < 6
      if password_confirmation.present? && password != password_confirmation
        raise ApiError.new("两次密码不一致", status: :unprocessable_entity)
      end
    end

    def synthetic_openid(account)
      "account_#{Digest::SHA256.hexdigest(account)[0, 24]}"
    end

    def bootstrap_user!(user, create_character: true)
      if create_character && user.characters.empty?
        CharacterCreationService.create_default_character!(user)
      end

      StoryService.initialize_progress!(user)
      LearningService.initialize_progress!(user)
      RoomService.setup_room!(user) unless user.user_room
      MapService.enter!(user) rescue nil
    end

    def auth_payload(user, is_new: false)
      character = user.active_character
      {
        user: user.as_json,
        token: user.auth_token,
        needs_customization: character.nil? || character.needs_customization?,
        is_new_user: is_new
      }
    end

    def resolve_openid(code)
      if Rails.env.production? && ENV["WECHAT_APP_ID"].present?
        fetch_wechat_openid(code)
      else
        "dev_#{Digest::SHA256.hexdigest(code.to_s)[0, 16]}"
      end
    end

    def fetch_wechat_openid(code)
      app_id = ENV.fetch("WECHAT_APP_ID")
      app_secret = ENV.fetch("WECHAT_APP_SECRET")
      uri = URI("https://api.weixin.qq.com/sns/jscode2session?appid=#{app_id}&secret=#{app_secret}&js_code=#{code}&grant_type=authorization_code")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)
      raise ApiError, data["errmsg"] || "微信登录失败" if data["errcode"].present?

      data["openid"]
    end
  end
end
