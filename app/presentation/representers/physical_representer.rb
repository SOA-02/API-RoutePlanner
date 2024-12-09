# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require 'ostruct'

module RoutePlanner
  module Representer
    # Represents essential Physical information for API output
    class Physical < Roar::Decorator
      include Roar::JSON

      property :course_id
      property :course_name
      property :credit
      property :language
      property :provider
      property :timeloc
    end
  end
end
