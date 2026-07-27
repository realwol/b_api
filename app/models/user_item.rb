# frozen_string_literal: true

class UserItem < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :quantity, numericality: { greater_than: 0 }

  def as_json(options = {})
    {
      id: id,
      quantity: quantity,
      item: item.as_json
    }
  end
end
