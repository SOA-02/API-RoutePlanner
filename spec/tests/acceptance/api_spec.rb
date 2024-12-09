# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  RoutePlanner::App
end

describe 'Test API routes' do
  include Rack::Test::Methods

  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_skill
    DatabaseHelper.wipe_database
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Root route' do
    it 'should return OK' do
      get '/'

      _(last_response.status).must_equal 200
      body = JSON.parse(last_response.body)
      _(body['status']).must_equal 'ok'
      _(body['message']).must_include 'api/v1'
    end
  end

  describe 'Add Map route' do
    before do
      @valid_params = { 'syllabus_title' => TITLE, 'syllabus_text' => SYLLABUS }
    end
    it 'validates valid syllabus request' do
      result = RoutePlanner::Request::NewMap.new(@valid_params).call
      _(result.success?).must_equal true
    end

    it 'rejects missing title' do
      invalid_params = @valid_params.clone
      invalid_params.delete('syllabus_title')
      result = RoutePlanner::Request::NewMap.new(invalid_params).call
      _(result.failure?).must_equal true
      _(result.failure.message).must_equal RoutePlanner::Request::NewMap::MSG_INVALID_TITLE
    end

    it 'rejects missing text' do
      invalid_params = @valid_params.clone
      invalid_params.delete('syllabus_text')
      result = RoutePlanner::Request::NewMap.new(invalid_params).call
      _(result.failure?).must_equal true
      _(result.failure.message).must_equal RoutePlanner::Request::NewMap::MSG_INVALID_TEXT
    end

    it 'rejects empty strings' do
      empty_params = {
        'syllabus_title' => '   ',
        'syllabus_text'  => '  '
      }
      result = RoutePlanner::Request::NewMap.new(empty_params).call
      _(result.failure?).must_equal true
    end

    it 'can process valid syllabus submission' do
      #Set JSON content type header
      header 'CONTENT_TYPE', 'application/json'

      post '/api/v1/maps', @valid_params.to_json

      _(last_response.status).must_equal 201
      # body = JSON.parse(last_response.body)
      # _(body['status']).must_equal 'created'
      # _(body['message']).must_include 'Map'
    end

    it 'checks Map Representer' do
      db_map = RoutePlanner::Repository::Maps.find_id(1)
      RoutePlanner::Representer::Map.new(db_map).to_json
    end

    it 'checks Skill Representer' do
      db_skill = RoutePlanner::Repository::Skills.find_skillid(1)
      RoutePlanner::Representer::Skill.new(db_skill).to_json
    end
  end
end
