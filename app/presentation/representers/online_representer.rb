# frozen_string_literal: true

require 'roar/decorator'
require 'roar/json'
require 'ostruct'

module RoutePlanner
  module Representer
    # Represents essential Member information for API output
    # USAGE:
    #  db_online=Repository::Onlines.find_original_id('87SH2Cn0s9A')
    # Representer::Online.new(db_online).to_json
    class Online < Roar::Decorator
      include Roar::JSON

      property :topic
      property :url
      property :platform
      property :for_skill
    end
  end
end
