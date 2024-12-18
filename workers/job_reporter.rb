# frozen_string_literal: true

require_relative 'progress_publisher'

module RoutePlanner
  # Report job progress to client
  class JobReporter
    attr_accessor :map
    
    def initialize(request_json, config)
      map_request = OpenAPI::MapMapper.new(request_json, config.OPENAI_KEY)

      @map = map_request.call
      @publisher = ProgressPublisher.new(config, map_request.id)
    end

    def report(msg)
      @publisher.publish(msg)
    end

    def report_each_second(seconds, &operation)
      seconds.times do
        sleep(1)
        report(operation.call)
      end
    end
  end
end
