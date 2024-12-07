# frozen_string_literal: true

require 'dry/transaction'

module RoutePlanner
  module Service
    # Fetch map skills and their challenge scores
    class FetchMapSkillRequire
      include Dry::Transaction

      MSG_MAP_NOT_FOUND = 'Map not found for the given name.'
      MSG_NO_SKILLS_FOUND = 'No skills found for the specified map.'
      MSG_SERVER_ERROR = 'An unexpected error occurred on the server. Please try again later.'

      step :find_map
      step :fetch_skills

      private

      # Step 1: Find the map by its name
      def find_map(map_name)
        map = Repository::For.klass(Entity::Map).find_mapid(map_name)
        return Failure(MSG_MAP_NOT_FOUND) unless map

        Success(map)
      rescue StandardError
        Failure(MSG_SERVER_ERROR)
      end

      # Step 2: Fetch skills associated with the map
      def fetch_skills(map_id)
        skills = Repository::For.klass(Entity::Skill).find_all_skills(map_id)
        return Failure(MSG_NO_SKILLS_FOUND) if skills.nil?

        return Failure(MSG_NO_SKILLS_FOUND) if skills.empty?

        Success(skills)
      rescue StandardError
        Failure(MSG_SERVER_ERROR)
      end
    end
  end
end
