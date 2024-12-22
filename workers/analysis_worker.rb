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

      def perform(_sqs_msg, request) # rubocop:disable Metrics/AbcSize
        puts 'WORKER: Processing request'
        # puts "WORKER: check request: #{request.inspect}"

        data = JSON.parse(request, symbolize_names: true)

        map = OpenAPI::MapMapper.new(data[:syllabus_text], Api.config.OPENAI_KEY).call
        # puts "WORKER: ANALYZE MAP: #{map.inspect}"
        store_map = Repository::For.klass(Entity::Map).build_map(map)

        # puts "WORKER: STORE MAP: #{store_map.inspect}"

        map_id = store_map[:map_id]
        # puts "WORKER: Map saved with ID: #{map_id}"

        skills = OpenAPI::SkillMapper.new(data[:syllabus_text], Api.config.OPENAI_KEY).call
        # puts "WORKER: ANALYZE SKILLS: #{skills.inspect}"

        # puts 'WORKER: Skills begin'
        skills.each do |skill|
          Repository::For.klass(Entity::Skill).build_skill(skill, map_id)
        end
        # puts 'WORKER: Skills end'

        # puts 'WORKER: Analysis completed'
      end
    end
  end
end
