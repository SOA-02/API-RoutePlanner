# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'

describe 'Tests Youtube API library' do
  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Search information' do
    before do
      @relevant_result = RoutePlanner::Youtube::VideoRecommendMapper
        .new(API_KEY)
        .find(KEY_WORD)
    end

    it 'HAPPY: search relevant gateway captures search relevant results' do
      @search_relevant_data = RoutePlanner::Youtube::YoutubeApi.new(API_KEY).search_relevant(KEY_WORD)
      _(@search_relevant_data).must_be_kind_of Hash
      _(@search_relevant_data['items']).must_be_kind_of Array
    end

    it 'HAPPY: recognize search relevant results' do
      assert_kind_of Array, @relevant_result
      refute_empty @relevant_result
      @relevant_result.each do |item|
        assert_kind_of RoutePlanner::Entity::Online, item
      end
    end

    it 'HAPPY: maps search data successfully' do
      @relevant_result.each do |item|
        _(item.topic).must_be_kind_of String
        _(item.url).must_be_kind_of String
        _(item.platform).must_be_kind_of String
      end
    end

    describe 'Video Information' do
      before do
        @video_data = RoutePlanner::Youtube::YoutubeApi.new(API_KEY).video_info(VIDEO_ID)
        @video_mapper = RoutePlanner::Youtube::VideoMapper.new(API_KEY).find(VIDEO_ID)
        # binding.irb
      end

      it 'HAPPY: fetches video data successfully' do
        _(@video_data).must_be_kind_of Hash
      end

      # it 'HAPPY: maps video data successfully' do
      #   _(@video_mapper).must_be_kind_of RoutePlanner::Entity::Youtubevideo
      # end

      it 'HAPPY: entity are of correct type' do
        _(@video_mapper.video_id).must_equal VIDEO_ID
        _(@video_mapper.video_duration).must_be_kind_of String
      end
    end
  end
end
