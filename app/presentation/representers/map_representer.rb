# rubocop:disable Style/OpenStructUse

require 'ostruct'
require 'roar/decorator'
require 'roar/json'

require_relative 'skill_representer'

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

      # collection :skills, extend: Representer::Skill, class: OpenStruct
    end
  end
end
