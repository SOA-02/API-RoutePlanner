# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Integration Tests of Youtube API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store videos' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: save yt api to database' do
      videos = RoutePlanner::Youtube::VideoRecommandMapper.new(API_KEY).find(KEY_WORD)
      _(videos).wont_be_empty
      _(videos).must_be_kind_of Array
      videos.each do |video|
        RoutePlanner::Repository::For.entity(video).build_online_resource(video) if video.id.nil?

        rebuilt = RoutePlanner::Repository::For.entity(video).find(video)
        _(rebuilt).wont_be_nil

        _(rebuilt.topic).must_equal(video.topic)
        _(rebuilt.url).must_equal(video.url)
        _(rebuilt.platform).must_equal(video.platform)
      end
    end
  end
end
