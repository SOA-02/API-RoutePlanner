# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'RoutePlanner Service Integration Test' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_nthusa
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store physical resource' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: should be able to find and save remote physical resource to database' do
      resources_made = RoutePlanner::Service::AddPhysicalResource.new.call(SKILL)
      # THEN: the result should report success..
      _(resources_made.success?).must_equal true

      # ..and provide a course entity with the right details
      rebuilt_message = resources_made.value!
      _(rebuilt_message).must_equal RoutePlanner::Service::AddPhysicalResource::MSG_PHYSICAL_RESOURCE_SAVE_SUCCESS
    end
  end
end
