# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'
require_relative '../../helpers/database_helper'
require 'rack/test'

def app
  RoutePlanner::Api
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

  describe 'Add maps route' do
    before do
      @valid_params = { syllabus_title: TITLE, syllabus_text: SYLLABUS }
    end
    it 'validates valid syllabus request' do
      result = RoutePlanner::Request::NewMap.new(@valid_params).call
      _(result.success?).must_equal true
    end

    it 'rejects missing title' do
      invalid_params = @valid_params.clone
      invalid_params.delete(:syllabus_title)
      result = RoutePlanner::Request::NewMap.new(invalid_params).call
      _(result.failure?).must_equal true
      _(result.failure.message).must_equal RoutePlanner::Request::NewMap::MSG_INVALID_TITLE
    end

    it 'rejects missing text' do
      invalid_params = @valid_params.clone
      invalid_params.delete(:syllabus_text)
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

    it 'should be able to add map and skill' do
      result = RoutePlanner::Service::AddMapandSkill.new.call(@valid_params)
      _(result.success?).must_equal true
    end

    it 'successfully creates a map and returns the correct response structure' do
      post '/api/v1/maps', {
        syllabus_title: @valid_params[:syllabus_title],
        syllabus_text: @valid_params[:syllabus_text]
      }.to_json, { 'CONTENT_TYPE' => 'application/json' }

      _(last_response.status).must_equal 201

      map = JSON.parse(last_response.body)['map']
      _(map['map_name']).must_equal @valid_params[:syllabus_title]
      _(map['map_description']).wont_be_empty

      skills = JSON.parse(last_response.body)['skills']
      _(skills).wont_be_empty
      _(skills).must_be_kind_of Array
    end
  #   it 'checks Map Representer' do
  #     db_map = RoutePlanner::Repository::Maps.find_id(1)
  #     RoutePlanner::Representer::Map.new(db_map).to_json
  #   end

  #   it 'checks Skill Representer' do
  #     db_skill = RoutePlanner::Repository::Skills.find_skillid(1)
  #     RoutePlanner::Representer::Skill.new(db_skill).to_json
  #   end
  end
end
