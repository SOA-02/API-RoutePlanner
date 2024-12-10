# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require 'ostruct'

require_relative 'online_representer'
require_relative 'physical_representer'

module RoutePlanner
  module Representer
    # Represents essential Study Stress information for API output
    class StudyStressOutput < Roar::Decorator
      include Roar::JSON

      property :map
      property :user_ability_value
      property :require_ability_value
      property :time
      property :stress_index
      collection :online_resources, extend: Representer::Online, class: OpenStruct
      collection :physical_resources, extend: Representer::Physical, class: OpenStruct
    end
  end
end
