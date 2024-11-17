# frozen_string_literal: true

module RoutePlanner
  module Youtube
    class VideoMapper
      def initialize(yt_key, gateway_class = YoutubeApi)
        @api_key = yt_key
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
          # value = @mapper_data['items'][0]['snippet']
          # puts "value being passed to Video.new: #{value.inspect}"
          # "value class: #{value.class}"

          RoutePlanner::Entity::Video.new(
            id: nil,
            video_id:,
            video_title:,
            video_published_at:,
            video_description:,
            video_thumbnail_url:
          )
        end

        private

        def video_id
          @mapper_data['items'][0]['id']
        end

        def video_title
          @mapper_data['items'][0]['snippet']['title']
        end

        def video_published_at
          @mapper_data['items'][0]['snippet']['publishedAt']
        end

        def video_description
          @mapper_data['items'][0]['snippet']['description']
        end

        def video_thumbnail_url
          @mapper_data['items'][0]['snippet']['thumbnails']['high']['url']
        end
      end
    end
  end
end
