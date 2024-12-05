# frozen_string_literal: true

require 'dry/transaction'

module RoutePlanner
  module Service
    # The AddOnlineResource class is responsible for managing and adding online resources
    # within the RoutePlanner service.
    class AddOnlineResource
      include Dry::Transaction
      MSG_ONLINE_RESOURCE_NOT_FOUND = 'Could not find any Online resource'
      MSG_ONLINE_RESOURCE_SAVE_SUCCESS = 'Online resource saved successfully.'
      MSG_SERVER_ERROR = 'An unexpected error occurred on the server. Please try again later.'
      MSG_ONLINE_RESOURCE_SAVE_FAIL = 'Online resource could not be saved.'
      MSG_VIDEO_DURATION_SAVE_FAIL = 'Video duration could not be saved.'

      step :find_oneline_resources
      step :store_oneline_resources

      private

      # Step 1: Find oneline resources
      def find_oneline_resources(skill)
        online_resources = online_resource_in_database(skill)
        online_resources = online_resource_from_youtube(skill) if online_resources.empty?

        Success(online_resources)
      rescue StandardError
        Failure(MSG_SERVER_ERROR)
      end

      # Step 2: Store resources that are not already in the database
      def store_oneline_resources(online_resources)
        online_resources.each do |entity|
          store_online_resource(entity) unless online_resource_find_original_id(entity.original_id)
        end
        Success(MSG_ONLINE_RESOURCE_SAVE_SUCCESS)
      rescue StandardError
        Failure(MSG_ONLINE_RESOURCE_SAVE_FAIL)
      end

      # Helper methods
      def online_resource_in_database(skill)
        Repository::For.klass(Entity::Online).find_all_resource_of_skills(skill)
      end

      def online_resource_from_youtube(skill)
        Youtube::VideoRecommendMapper.new(App.config.API_KEY).find(skill)
      rescue StandardError
        Failure(MSG_ONLINE_RESOURCE_NOT_FOUND)
      end

      def online_resource_find_original_id(original_id)
        Repository::For.klass(Entity::Online).find_original_id(original_id)
      end

      def store_online_resource(entity)
        Repository::For.entity(entity).build_online_resource(entity)
      rescue StandardError
        Failure(MSG_ONLINE_RESOURCE_SAVE_FAIL)
      end
    end
  end
end
