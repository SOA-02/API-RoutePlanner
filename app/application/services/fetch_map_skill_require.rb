# frozen_string_literal: true

require 'dry/monads'

module RoutePlanner
  module Service
    # logic of fetching viewed resources
    class FetchMapSkillRequire
      include Dry::Monads::Result::Mixin
      MSG_SERVER_ERROR = 'An unexpected error occurred on the server. Please try again later.'

      def call(skill)
        resources = fetch_resources(skill)

        return Success(resources) unless resources_empty?(resources)

        Failure('No resources found')
      rescue StandardError
        Failure(MSG_SERVER_ERROR)
      end

      private

      def fetch_resources(skill)
        {
          physical_resources: fetch_physical_resources(skill),
          online_resources: fetch_online_resources(skill)
        }
      end

      def fetch_physical_resources(skill)
        Repository::For.klass(Entity::Physical).find_all_resource_of_skills(skill) || []
      end

      def fetch_online_resources(skill)
        Repository::For.klass(Entity::Online).find_all_resource_of_skills(skill) || []
      end

      def resources_empty?(resources)
        resources[:physical_resources].empty? && resources[:online_resources].empty?
      end
    end
  end
end
