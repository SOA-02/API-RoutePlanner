# frozen_string_literal: true

module RoutePlanner
  module Nthusa
    class PhysicalRecommendMapper # rubocop:disable Style/Documentation
      def initialize(gateway_class = NthusaApi)
        @gateway_class = gateway_class # 初始化實例變數
        @gateway = @gateway_class.new
      end

      def load_several(url)
        @gateway.nthusa_search_recommend(url).map do |data|
          DataMapper.new(data).build_entity
        end
      end

      def find(pre_req)
        course_data = fetch_course_data(pre_req)
        return 'Course  data is missing' unless course_data&.any?

        map_to_entities(course_data)
      end

      private

      def fetch_course_data(pre_req)
        @gateway.nthusa_search_recommend(pre_req)
        
      end

      def map_to_entities(course_items)
        course_items.map { |item| DataMapper.new(item).build_entity }
      end

      # Extracts entity specific elements from data structure
      class DataMapper
        def initialize(data)
          @data = data
          raise 'Snippet data missing' unless @data
        end

        def build_entity
          Entity::Physical.new(
            id: nil,
            course_id:,
            course_name:,
            credit:,
            language:,
            provider:,
            timeloc:
          )
        end

        private

        def course_id
          @data['id']
        end

        def course_name
          @data['english_title']
        end

        def credit
          @data['credit']
        end

        def language
          @data['language']
        end

        def provider
          @data['language']
        end

        def teacher
          @data['language']
        end

        def timeloc
          @data['class_room_and_time']
        end
      end
    end
  end
end
