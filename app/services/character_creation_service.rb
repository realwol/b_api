# frozen_string_literal: true

class CharacterCreationService
  class << self
    def create_default_character!(user, name: "小雪")
      user.characters.create!(
        name: name,
        appearance: Character::DEFAULT_APPEARANCE.dup,
        is_active: true
      )
    end

    def create!(user, params)
      user.characters.update_all(is_active: false) if params[:is_active] != false

      user.characters.create!(
        name: params[:name] || "新伙伴",
        appearance: params[:appearance] || Character::DEFAULT_APPEARANCE.dup,
        is_active: params.fetch(:is_active, true)
      )
    end
  end
end
