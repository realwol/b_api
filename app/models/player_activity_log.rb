# frozen_string_literal: true

class PlayerActivityLog < ApplicationRecord
  belongs_to :user
  belongs_to :game_map, optional: true

  ACTIVITY_TYPES = %w[
    map_enter map_move explore sensor_trigger gps_enter ble_detect
    task_start task_complete reward_grant shop_purchase care_action
    learning_start learning_complete skill_upgrade check_in redeem
  ].freeze

  validates :activity_type, presence: true, inclusion: { in: ACTIVITY_TYPES }
  validates :occurred_at, presence: true

  scope :recent, -> { order(occurred_at: :desc) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :user_id, :game_map_id, :activity_type, :ref_type, :ref_id,
             :payload, :occurred_at, :created_at]
    ))
  end
end
