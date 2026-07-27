# frozen_string_literal: true

class ExpRecord < ApplicationRecord
  belongs_to :user
  belongs_to :character, optional: true

  SOURCES = %w[
    care story learning achievement daily_check_in
    decoration character_level
  ].freeze

  validates :amount, :total_after, :source, presence: true

  def as_json(options = {})
    super(options.merge(only: [:id, :amount, :total_after, :source, :description, :created_at]))
  end
end
