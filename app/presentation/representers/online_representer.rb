# frozen_string_literal: true
require 'ostruct'
require 'roar/decorator'
require 'roar/json'

module RoutePlanner
  module Representer
    # Represents essential Online resource for API output
    # USAGE:
    #  db_online=Repository::Onlines.find_original_id('87SH2Cn0s9A')
    # Representer::Online.new(db_online).to_json
    class Online < Roar::Decorator
      include Roar::JSON

      property :topic
      property :url
      property :platform
      property :video_duration
    end
  end
end
