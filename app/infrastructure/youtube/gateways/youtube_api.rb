# frozen_string_literal: true

require 'http'
require 'yaml'

module RoutePlanner
  # Represents interactions with the Youtube .
  module Youtube
    # Library for Youtube Web API
    class YoutubeApi
      def initialize(api_key)
        @api_key = api_key
      end

      def search_relevant(keyword)
        Request.new(@api_key).yt_search_relevant_path(keyword).parse
      end

      def video_info(video_id)
        Request.new(@api_key).yt_video_path(video_id).parse
      end

      # Sends out HTTP requests to Youtube
      class Request
        YT_API_ROOT = 'https://www.googleapis.com/youtube/v3'
        MAX_RESULTS = Value::YoutubeSearch.max_results
        def initialize(api_key)
          @api_key = api_key
        end

        def yt_search_relevant_path(keyword)
          modified_keyword = RoutePlanner::Value::YoutubeSearch.modified_keyword(keyword)
          get(YT_API_ROOT + "/search?part=snippet&maxResults=#{MAX_RESULTS}&type=video&q=#{modified_keyword}&key=#{@api_key}") # rubocop:disable Layout/LineLength
        end

        def yt_video_path(video_id)
          get(YT_API_ROOT + "/videos?part=contentDetails&id=#{video_id}&key=#{@api_key}")
        end

        def get(url)
          http_response = HTTP.headers('Accept' => 'application/json').get(url)
          Response.new(http_response).tap do |response|
            raise(response.error) unless response.successful?
          end
        end
      end

      # Decorates HTTP responses from Youtube with success/error

      class Response < SimpleDelegator # rubocop:disable Style/Documentation
        NotFound = Class.new(StandardError)
        HTTP_ERROR = {
          404 => NotFound
        }.freeze

        def successful?
          HTTP_ERROR.keys.none?(code)
        end

        def error
          HTTP_ERROR[code]
        end
      end
    end
  end
end
