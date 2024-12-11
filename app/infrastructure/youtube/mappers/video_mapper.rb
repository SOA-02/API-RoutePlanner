# frozen_string_literal: true

module RoutePlanner
  module Youtube
    # Maps Youtube video data to entity object
    class VideoMapper
      def initialize(api_key, gateway_class = YoutubeApi)
        @api_key = api_key
        @gateway_class = gateway_class
        @gateway = gateway_class.new(@api_key)
      end

      def find(video_id)
        video_data = @gateway.video_info(video_id)
        build_entity(video_data)
      end

      def build_entity(video_data)
        DataMapper.new(video_data).build_entity_map
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(mapper_data)
          @mapper_data = mapper_data
        end

        def build_entity_map
          RoutePlanner::Entity::Youtubevideo.new(
            id: nil,
            video_id:,
            video_duration:
          )
        end

        private

        def video_id
          @mapper_data['items'][0]['id']
        end

        def video_duration
          @mapper_data['items'][0]['contentDetails']['duration']
        end
      end
    end
  end
end
