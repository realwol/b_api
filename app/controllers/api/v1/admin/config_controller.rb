# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ConfigController < BaseController
        def overview
          render json: {
            maps: GameMap.count,
            zones: MapZone.count,
            event_templates: EventTemplate.count,
            sensor_triggers: SensorTrigger.count,
            learning_categories: LearningCategory.count,
            event_types: EventTemplate::EVENT_TYPES,
            sensor_types: SensorTrigger::SENSOR_TYPES,
            zone_types: MapZone::ZONE_TYPES
          }
        end
      end
    end
  end
end
