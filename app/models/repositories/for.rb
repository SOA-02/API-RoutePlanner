# frozen_string_literal: true

module Outline
  module Repository
    module For
      ENTITY_REPOSITORY = {
        Entity::Video => Videos
      }.freeze

      def self.klass(entity_klass)
        ENTITY_REPOSITORY[entity_klass]
      end

      def self.entity(entity_object)
        ENTITY_REPOSITORY[entity_object.class]
      end
    end
  end
end
