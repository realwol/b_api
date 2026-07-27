# frozen_string_literal: true

module Api
  module V1
    class CharactersController < BaseController
      before_action :set_character, only: [:show, :update, :care, :care_logs]

      def index
        characters = current_user.characters.order(created_at: :desc)
        characters.each(&:apply_stat_decay!)
        render json: { characters: characters.map(&:as_json) }
      end

      def show
        @character.apply_stat_decay!
        render json: { character: @character.as_json }
      end

      def create
        character = CharacterCreationService.create!(current_user, character_params)
        render json: { character: character.as_json }, status: :created
      end

      def customize
        character = current_user.active_character
        if character&.needs_customization?
          character = CharacterCreationService.update_customization!(current_user, character, customize_params)
        else
          character = CharacterCreationService.complete_customization!(current_user, customize_params)
        end
        render json: {
          character: character.as_json,
          needs_customization: false
        }
      end

      def update
        @character.update!(character_params)
        render json: { character: @character.as_json }
      end

      def care
        item = Item.find(params[:item_id]) if params[:item_id].present?
        result = CareService.perform!(
          @character,
          action_type: params.require(:action_type),
          item: item,
          appearance: params[:appearance]&.to_unsafe_h
        )
        render json: result
      end

      def care_logs
        logs = @character.care_logs.order(created_at: :desc).limit(20)
        render json: { care_logs: logs.map(&:as_json) }
      end

      private

      def set_character
        @character = current_user.characters.find(params[:id])
      end

      def character_params
        params.permit(:name, :is_active, appearance: {})
      end

      def customize_params
        params.permit(:name, :gender, :hairstyle, :personality, :face, :height)
      end
    end
  end
end
