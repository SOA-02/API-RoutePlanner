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

  describe 'Add Map route' do
    it 'should be able to add a syllabus to openai' do
      map = RoutePlanner::Service::AddMap.new.call(
        syllabus_title: TITLE,
        syllabus_text: SYLLABUS
      )
      binding.irb

      req_header = { 'CONTENT_TYPE' => 'text/plain' }
    
      post '/api/v1/RoutePlanners?map=Test', 
         SYLLABUS,
         req_header

      _(last_response.status).must_equal 201

    end
  end
end
