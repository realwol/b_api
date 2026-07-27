# frozen_string_literal: true

class UserMapEvent < ApplicationRecord
  belongs_to :user
  belongs_to :event_template
  belongs_to :game_map
  belongs_to :map_zone, optional: true

  STATUSES = %w[pending in_progress completed failed expired].freeze
  TRIGGER_SOURCES = %w[explore sensor admin spawn].freeze

  validates :status, inclusion: { in: STATUSES }
  validates :trigger_source, inclusion: { in: TRIGGER_SOURCES }

  scope :active_events, -> { where(status: %w[pending in_progress]) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :event_template_id, :game_map_id, :map_zone_id, :status,
             :trigger_source, :pos_x, :pos_y, :event_snapshot, :rewards_granted,
             :result_data, :started_at, :completed_at, :sensor_key, :created_at],
      include: { event_template: { only: [:id, :key, :name, :event_type, :difficulty] } }
    ))
  end
end
