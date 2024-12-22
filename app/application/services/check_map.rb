# frozen_string_literal: true

require 'dry/monads'

module RoutePlanner
  module Service
    # The CheckExistingMap class is responsible for managing and checking existing maps
    class CheckExistingMap
      include Dry::Monads[:result]

      def call(input)
        map = map_in_database(input[:syllabus_title])
        if  map
          skills = skills_in_database(map.id)
          Success(APIResponse::ApiResult
            .new(status: :ok, message: OpenStruct.new({ map: map, skills: skills }))) # rubocop:disable Style/OpenStructUse
        else
          Failure('Map not found')
        end
      rescue StandardError
        Failure('Error finding map')
      end

      private

      def map_in_database(map_name)
        Repository::For.klass(Entity::Map).find_map_name(map_name)
      end

      def skills_in_database(map_id)
        Repository::For.klass(Entity::Skill).find_all_skills(map_id)
      end
    end
  end
end
