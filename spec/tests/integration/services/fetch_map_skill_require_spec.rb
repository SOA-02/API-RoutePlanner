# frozen_string_literal: true

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'RoutePlanner Service Integration Test' do
  VcrHelper.setup_vcr

  # before do
  #   VcrHelper.configure_vcr_for_youtube
  # end

  after do
    VcrHelper.eject_vcr
  end

  describe 'RoutePlanner fetch  map_skill requir' do
    before do
      DatabaseHelper.wipe_database
    end
    it 'HAPPY: should return success when map and skills are found' do
      result = RoutePlanner::Service::FetchMapSkillRequire.new.call(TITLE)
      # Assert
      _(result.value!).must_be_instance_of Hash
      _(result.value!).wont_be_empty
      expected_keys = ['Data Mining', 'Machine Learning', 'Statistics', 'Python Programming', 'Business Analytics']
      missing_keys = expected_keys - result.value!.keys
      _(missing_keys.empty?).must_equal true, "Missing keys: #{missing_keys}"
      # 確認 values 不為空
      _(result.value!.values).wont_be_empty
    end

    it 'SAD: should return failure when map name does not exist' do
      # Act
      name = 'Nonexistent Map'
      result = RoutePlanner::Service::FetchMapSkillRequire.new.call(name)

      # Assert
      _(result.failure?).must_equal true
      _(result.failure).must_equal RoutePlanner::Service::FetchMapSkillRequire::MSG_SERVER_ERROR
    end

    it 'SAD: should return failure when map name is nil or empty' do
      result_nil = RoutePlanner::Service::FetchMapSkillRequire.new.call(nil)
      result_empty = RoutePlanner::Service::FetchMapSkillRequire.new.call('')

      _(result_nil.failure?).must_equal true
      _(result_nil.failure).must_equal RoutePlanner::Service::FetchMapSkillRequire::MSG_SERVER_ERROR

      _(result_empty.failure?).must_equal true
      _(result_empty.failure).must_equal RoutePlanner::Service::FetchMapSkillRequire::MSG_SERVER_ERROR
    end
  end
end
