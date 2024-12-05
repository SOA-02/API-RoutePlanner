# frozen_string_literal: true

module RoutePlanner
  module Mixins
    # Utility for converting ISO 8601 duration to hours
    module DurationConverter
      def self.iso8601_duration_to_hours(video_duration)
        match = /PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/.match(video_duration)
        return 0 unless match

        hours = match[1].to_i
        minutes = match[2].to_i / 60.0
        seconds = match[3].to_i / 3600.0
        hours + minutes + seconds
      end
    end
  end
end
