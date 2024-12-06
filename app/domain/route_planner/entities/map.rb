# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RoutePlanner
  module Entity
    # Domain entity for map
    class Map < Dry::Struct
      include Dry.Types()

      attribute :id, Integer.optional
      attribute :map_name, Strict::String
      attribute :map_description, Strict::String
      attribute :map_evaluation, Strict::String
      attribute :map_ai, Strict::String

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end
