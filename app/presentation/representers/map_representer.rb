require 'roar/decorator'
require 'roar/json'

module RoutePlanner
  module Representer
    # Represents Map information
    class Map < Roar::Decorator
      include Roar::JSON

      property :map_name
      property :map_description
      property :map_evaluation
      property :map_ai
    end
  end
end
