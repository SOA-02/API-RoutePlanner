# frozen_string_literal: true

require_relative '../require_app'

require_app

require 'figaro'
require 'shoryuken'

# Shoryuken worker class to clone repos in parallel
class AnalysisWorker
  Figaro.application = Figaro::Application.new(
    environment: ENV['RACK_ENV'] || 'development',
    path: File.expand_path('config/secrets.yml')
  )
  Figaro.load
  def self.config = Figaro.env

  Shoryuken.sqs_client = Asw::SQS::Client.new(
    access_key_id: config.AWS_ACCESS_KEY_ID,
    secret_access_key: config.AWS_SECRET_ACCESS_KEY,
    region: config.AWS_REGION
  )

  include Shoryuken::Worker
  shoryuken_options queue: config.CLONE_QUEUE_NAME, auto_delete: true

  def perform(_sqs_msg, request_json)
    request = JSON.parse(request_json, symbolize_names: true)
    # map_and_skills = RoutePlanner::Representer::AddMapandSkill
    #   .new(OpenStruct.new)
    #   .from_json(request)
    
    # map_entity = map_and_skills.map
    # skill_entities = map_and_skills.skills
  end
end