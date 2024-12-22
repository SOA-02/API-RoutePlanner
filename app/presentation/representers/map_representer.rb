# frozen_string_literal: true

require 'ostruct'
require 'roar/decorator'
require 'roar/json'

module RoutePlanner
  # Represents Map information for API output
  module Representer
    # Represents Map information for API output
    class Map < Roar::Decorator
      include Roar::JSON

      property :map_name
      property :map_description
      property :map_evaluation
      property :map_ai
    end
  end
end
