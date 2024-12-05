# frozen_string_literal: true

require 'dry/monads'

module RoutePlanner
  module Service
    # The AddResources class is responsible for managing and adding resources
    class AddResources
      include Dry::Monads::Result::Mixin

      def initialize(online_service: default_online_service, physical_service: default_physical_service)
        @online_service = online_service
        @physical_service = physical_service
      end

      def call(online_skill:, physical_skill:)
        online_result, physical_result = fetch_results(online_skill, physical_skill)
        partial_results = build_partial_results(online_result, physical_result)
        failures = find_failures([online_result, physical_result])

        handle_results(partial_results, failures)
      end

      private

      def fetch_results(online_skill, physical_skill)
        [
          @online_service.call(online_skill),
          @physical_service.call(physical_skill)
        ]
      end

      def build_partial_results(online_result, physical_result)
        {
          online_resources: self.class.extract_value_if_success(online_result),
          physical_resources: self.class.extract_value_if_success(physical_result)
        }
      end

      def find_failures(results)
        results.compact.select(&:failure?)
      end

      def handle_results(partial_results, failures)
        return Success(partial_results) if partial_results.values.any?

        Failure(
          message: failures.map(&:failure).join(', '),
          partial_results: partial_results
        )
      end

      def default_online_service
        @default_online_service ||= Service::AddOnlineResource.new
      end

      def default_physical_service
        @default_physical_service ||= Service::AddPhysicalResource.new
      end

      # Extracted as a class-level method
      def self.extract_value_if_success(result)
        result.success? ? result.value! : nil
      end
    end
  end
end
