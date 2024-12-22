# frozen_string_literal: true

require 'dry/monads'

module RoutePlanner
  module Service
    # The CreateMap class is responsible for managing and creating maps
    class CreateMap
      include Dry::Monads[:result]

      def call(input)
        message = {
          syllabus_text: input[:syllabus_text],
          syllabus_title: input[:syllabus_title]
        }.to_json

        Messaging::Queue.new(Api.config.CLONE_QUEUE_URL, Api.config).send(message)

        Failure(APIResponse::ApiResult.new(
                  status: :processing, message: 'Map is being processed. Please try again later.'
                ))
      rescue StandardError => e
        Failure("Error creating map: #{e.message}")
      end
    end
  end
end
