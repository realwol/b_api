# frozen_string_literal: true

class UserDecoration < ApplicationRecord
  belongs_to :user
  belongs_to :decoration

  validates :quantity, numericality: { greater_than: 0 }

  def as_json(options = {})
    { id: id, quantity: quantity, decoration: decoration.as_json }
  end
end
