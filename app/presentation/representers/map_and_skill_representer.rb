# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

require_relative 'map_representer'
module RoutePlanner
  module Representer
    # Represents Skill information
    class AddMapandSkill < Roar::Decorator
      include Roar::JSON
      property :map, extend: Representer::Map, class: OpenStruct # rubocop:disable Style/OpenStructUse
      property :skills
    end
  end
end
