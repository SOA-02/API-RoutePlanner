# frozen_string_literal: true

require_relative 'onlines'
require_relative 'physicals'
require_relative 'skills'
require_relative 'maps'
# require_relative 'map_skills'

module RoutePlanner
  module Repository
    # Finds the right repository for an entity object or class
    module For
      ENTITY_REPOSITORY = {
        Entity::Online   => Onlines,
        Entity::Physical => Physicals,
        Entity::Skill    => Skills,
        Entity::Map      => Maps
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
