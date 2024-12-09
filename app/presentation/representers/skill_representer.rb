# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'

module RoutePlanner
  module Representer
    # Represents Skill information
    class Skill < Roar::Decorator
      include Roar::JSON

      property :skill_name
      property :challenge_score
    end
  end
end
