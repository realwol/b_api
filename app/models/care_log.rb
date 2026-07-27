# frozen_string_literal: true

class CareLog < ApplicationRecord
  belongs_to :character
  belongs_to :item, optional: true

  ACTION_TYPES = %w[feed play dress talk rest gift use_item].freeze

  validates :action_type, inclusion: { in: ACTION_TYPES }

  def as_json(options = {})
    super(options.merge(
      only: [:id, :action_type, :result, :created_at],
      include: { item: { only: [:id, :name, :icon_url] } }
    ))
  end
end
