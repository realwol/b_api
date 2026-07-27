# frozen_string_literal: true

module Api
  module V1
    class StoryController < BaseController
      def chapters
        render json: { chapters: StoryService.chapters_for(current_user) }
      end

      def start
        episode = StoryEpisode.find(params[:id])
        result = StoryService.start_episode!(current_user, episode)
        render json: result
      end

      def complete
        episode = StoryEpisode.find(params[:id])
        result = StoryService.complete_episode!(current_user, episode, choice: params[:choice])
        render json: result
      end
    end
  end
end
