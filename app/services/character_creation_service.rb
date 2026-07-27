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

    def complete_customization!(user, params)
      appearance = build_appearance(params)
      name = params[:name].presence || "小花儿"

      user.characters.update_all(is_active: false)
      character = user.characters.create!(
        name: name,
        appearance: appearance,
        is_active: true
      )

      user.update!(tutorial_completed: true)

      StoryService.initialize_progress!(user)
      LearningService.initialize_progress!(user)
      RoomService.setup_room!(user) unless user.user_room
      MapService.enter!(user) rescue nil

      character
    end

    def update_customization!(user, character, params)
      appearance = build_appearance(params, base: character.appearance)
      name = params[:name].presence || character.name
      character.update!(name: name, appearance: appearance)
      user.update!(tutorial_completed: true)
      character
    end

    private

    def build_appearance(params, base: {})
      merged = Character::DEFAULT_APPEARANCE.merge(base.stringify_keys)
      hairstyle = params[:hairstyle].presence || merged["hairstyle"] || "long_black"
      {
        "gender" => params[:gender].presence || merged["gender"] || "female",
        "hairstyle" => hairstyle,
        "personality" => params[:personality].presence || merged["personality"] || "gentle",
        "face" => params[:face].presence || merged["face"] || "round",
        "height" => params[:height].presence || merged["height"] || "medium",
        "hair" => hairstyle,
        "outfit" => merged["outfit"] || "default_dress",
        "skin_tone" => merged["skin_tone"] || "fair",
        "accessory" => merged["accessory"] || "ribbon",
        "customized" => true
      }
    end
  end
end
