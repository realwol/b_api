# frozen_string_literal: true

module Api
  module V1
    module Admin
      class ConfigController < BaseController
        def overview
          render json: {
            maps: GameMap.count,
            scenic_maps: GameMap.scenic.count,
            trigger_points: MapTriggerPoint.count,
            map_tasks: MapTask.count,
            activity_logs: PlayerActivityLog.count,
            zones: MapZone.count,
            event_templates: EventTemplate.count,
            sensor_triggers: SensorTrigger.count,
            learning_categories: LearningCategory.count,
            event_types: EventTemplate::EVENT_TYPES,
            sensor_types: SensorTrigger::SENSOR_TYPES,
            trigger_types: MapTriggerPoint::TRIGGER_TYPES,
            task_types: MapTask::TASK_TYPES,
            activity_types: PlayerActivityLog::ACTIVITY_TYPES,
            zone_types: MapZone::ZONE_TYPES
          }
        end
      end
    end
  end
end
