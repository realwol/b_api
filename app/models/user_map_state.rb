# frozen_string_literal: true

class UserMapState < ApplicationRecord
  belongs_to :user
  belongs_to :game_map

  def as_json(options = {})
    super(options.merge(
      only: [:id, :game_map_id, :pos_x, :pos_y, :entered_at, :last_explored_at, :explore_count]
    ))
  end
end
