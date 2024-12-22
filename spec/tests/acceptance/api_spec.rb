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
  end

  describe 'Add maps route' do
    before do
      @valid_params = { syllabus_title: TITLE, syllabus_text: SYLLABUS }
      existing_map = RoutePlanner::Repository::For.klass(RoutePlanner::Entity::Map).find_map_name(TITLE)
      skills = RoutePlanner::Repository::For.klass(RoutePlanner::Entity::Skill).find_all_skills(existing_map.id)
      possible_values = [1, 20, 40, 60]
      @body = {
        "#{TITLE}_skills" => {}
      }
      skills.each do |skill|
        @body["#{TITLE}_skills"][skill] = possible_values.sample.to_s
      end
      puts JSON.pretty_generate(@body)
    end
    it 'validates valid skull request' do
      result = RoutePlanner::Request::SkillsForm.new(@body).call
      _(result.success?).must_equal true
    end

    it 'rejects empty skill' do
      result = RoutePlanner::Request::SkillsForm.new('').call
      _(result.failure?).must_equal true
      _(result.failure.first).must_equal RoutePlanner::Request::SkillsForm::MSG_EMPTY_SKILLS
    end

    #   empty_params = {
    #     'syllabus_title' => '   ',
    #     'syllabus_text'  => '  '
    #   }
    #   result = RoutePlanner::Request::NewMap.new(empty_params).call
    #   _(result.failure?).must_equal true
    # end

    it 'should be able to get ProcessUserAbilityValue data' do
      result = RoutePlanner::Service::ProcessUserAbilityValue.new.call(@body)
      _(result.success?).must_equal true
    end

    it 'successfully creates a rescource and returns the correct response structure' do
      post '/api/v1/RoutePlanner', @body.to_json, { 'CONTENT_TYPE' => 'application/json' }

      _(last_response.status).must_equal 201

      response_body = JSON.parse(last_response.body)
      # Check if the 'map' key exists and is not nil
      _(response_body).must_include 'map'
      map = response_body['map']
      _(map).wont_be_nil # Ensure 'map' is not nil
      _(map).must_equal @valid_params[:syllabus_title]

      _(response_body).must_include 'user_ability_value'
      user_ability_value = response_body['user_ability_value']
      _(user_ability_value).wont_be_nil
      _(user_ability_value).must_be_kind_of Hash

      _(response_body).must_include 'require_ability_value'
      require_ability_value = response_body['require_ability_value']
      _(require_ability_value).wont_be_nil
      _(require_ability_value).must_be_kind_of Hash

      _(response_body).must_include 'time'
      time = response_body['time']
      _(time).wont_be_nil
      _(time).must_be_kind_of Integer

      _(response_body).must_include 'stress_index'
      stress_index = response_body['stress_index']
      _(stress_index).wont_be_nil
      _(stress_index).must_be_kind_of Hash
      _(stress_index['pressure_index']).must_be_kind_of Integer
      _(stress_index['stress_level']).must_be_kind_of String

      _(response_body).must_include 'online_resources'
      online_resources = response_body['online_resources']
      _(online_resources).wont_be_nil
      _(online_resources).must_be_kind_of Array
      _(online_resources.all? { |resource| resource.key?('topic') }).must_equal true
      _(online_resources.all? { |resource| resource.key?('url') }).must_equal true

      _(response_body).must_include 'physical_resources'
      response_body['physical_resources']
      physical_resources = response_body['physical_resources']
      _(physical_resources).wont_be_nil
      _(physical_resources).must_be_kind_of Array
      _(physical_resources.all? { |resource| resource.key?('course_id') }).must_equal true
      _(physical_resources.all? { |resource| resource.key?('course_name') }).must_equal true
      _(physical_resources.all? { |resource| resource.key?('credit') }).must_equal true
    end
  end
end
