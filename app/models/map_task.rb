# frozen_string_literal: true

class MapTask < ApplicationRecord
  belongs_to :game_map
  belongs_to :map_trigger_point, optional: true
  belongs_to :event_template, optional: true
  has_many :user_map_task_progresses, dependent: :destroy

  TASK_TYPES = %w[checkpoint mini_game collect route_complete].freeze

  validates :key, :name, :task_type, presence: true
  validates :key, uniqueness: { scope: :game_map_id }
  validates :task_type, inclusion: { in: TASK_TYPES }

  scope :active, -> { where(is_active: true) }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :game_map_id, :key, :name, :description, :task_type,
             :tier_level, :sort_order, :map_trigger_point_id, :event_template_id,
             :requirements, :score_tiers, :rewards_config, :is_active]
    ))
  end

  def rewards_for_score(score)
    tiers = Array(score_tiers).map(&:with_indifferent_access).sort_by { |t| -t[:min_score].to_i }
    tier = tiers.find { |t| score.to_i >= t[:min_score].to_i && score.to_i <= t[:max_score].to_i }
    tier&.dig(:rewards_config) || rewards_config
  end
end
