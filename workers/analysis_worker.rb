# frozen_string_literal: true

require_relative '../require_app'

require_app

require 'figaro'
require 'shoryuken'

module RoutePlanner
  # Shoryuken worker class to clone repos in parallel
  module Workers
    # Worker to analyze the map
    class AnalysisWorker
      Figaro.application = Figaro::Application.new(
        environment: ENV['RACK_ENV'] || 'development',
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      Shoryuken.sqs_client = Aws::SQS::Client.new(
        access_key_id: config.AWS_ACCESS_KEY_ID,
        secret_access_key: config.AWS_SECRET_ACCESS_KEY,
        region: config.AWS_REGION
      )

      include Shoryuken::Worker
      shoryuken_options queue: config.CLONE_QUEUE_URL, auto_delete: true

      def perform(_sqs_msg, request)
        puts 'MAP WORKER: Processing request'
        map = OpenAPI::MapMapper.new(request, Api.config.OPENAI_KEY).call
        puts "MAP WORKER: Analysis completed: #{map.inspect}"
      end
    end
  end
end
