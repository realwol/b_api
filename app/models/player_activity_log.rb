# frozen_string_literal: true

class PlayerActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :game_map, optional: true

  CATEGORIES = %w[business api client auth].freeze

  ACTIVITY_TYPES = %w[
    map_enter map_move explore sensor_trigger gps_enter ble_detect
    task_start task_complete reward_grant shop_purchase care_action
    learning_start learning_complete skill_upgrade check_in redeem
    page_view ui_click api_request api_read story_start story_complete
    story_view shop_view inventory_use room_update auth_login auth_logout
    auth_register character_create character_update profile_update
    achievement_view wallet_view daily_check_in customize_character
    navigation scene_load error client_event
  ].freeze

  validates :activity_type, presence: true, length: { maximum: 64 }
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_map, ->(map_id) { where(game_map_id: map_id) }
  scope :by_category, ->(cat) { where(category: cat) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :user_id, :game_map_id, :category, :activity_type, :action,
             :page, :session_id, :request_method, :request_path, :status_code,
             :success, :ref_type, :ref_id, :payload, :occurred_at, :created_at]
    ))
  end
end
