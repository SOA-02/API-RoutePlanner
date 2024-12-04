# frozen_string_literal: true

module RoutePlanner
  module Youtube
    class VideoRecommendMapper # rubocop:disable Style/Documentation
      def initialize(api_key, gateway_class = YoutubeApi)
        @api_key = api_key
        @gateway_class = gateway_class
        @gateway = @gateway_class.new(@api_key)
      end

      def load_several(url)
        @gateway.search_relevant(url).map do |data|
          DataMapper.new(data).build_entity
        end
      end

      def find(key_word)
        item_data = fetch_item_data(key_word)
        return 'Video data is missing' unless item_data&.any?

        video_items = filter_video_items(item_data)
        return 'No video items found' if video_items.empty?

        map_to_entities(video_items, key_word)
      end

      private

      def fetch_item_data(key_word)
        data = @gateway.search_relevant(key_word)
        data['items']
      end

      def map_to_entities(video_items, key_word)
        video_items.map { |item| DataMapper.new(item, key_word).build_entity }
      end

      def filter_video_items(item_data)
        resource_type = Value::YoutubeSearch.resource_type
        item_data.select { |item| item['id']['kind'] == resource_type }
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data, key_word)
          @data = data
          @key_word = key_word
          raise 'Snippet data missing' unless @data
        end

        def build_entity
          Entity::Online.new(
            id: nil,
            original_id:,
            topic:,
            url:,
            platform:,
            video_duration:,
            for_skill: @key_word
          )
        end

        private

        def original_id
          @data['id']['videoId']
        end

        def url
          "https://www.youtube.com/watch?v=#{@data['id']['videoId']}"
        end

        def topic
          @data['snippet']['title']
        end

        def platform
          Value::YoutubeSearch.platform
        end

        def video_duration
          Youtube::VideoMapper.new(App.config.API_KEY).find(@data['id']['videoId']).video_duration
        end
      end
    end
  end
end
