# frozen_string_literal: true

module RoutePlanner
  module Value
    # Calculate time spent on resources
    class ResourceTimeCalculator
      def self.compute_online_resource(original_ids)
        total_hours = original_ids.sum do |original_id|
          iso8601_duration_to_hours(
            Youtube::VideoMapper.new(App.config.API_KEY).find(original_id).video_duration
          )
        end
        total_hours.ceil
      end

      def self.compute_total_online_time(resources)
        online_original_ids = resources.flat_map { |resource| resource[:online_resources].map(&:original_id) }
        compute_online_resource(online_original_ids)
      end

      def self.compute_physical_time(physical_credits)
        physical_credits.map { |credit| Entity::Physical.minimum_time_required(credit) }.sum
      end

      def self.compute_total_physical_time(resources)
        physical_credits = resources.flat_map { |resource| resource[:physical_resources].map(&:credit) }
        compute_physical_time(physical_credits)
      end

      def self.compute_minimum_time(resources)
        total_physical_time = compute_total_physical_time(resources)
        total_online_time = compute_total_online_time(resources)

        total_physical_time + total_online_time
      end

      # Helper method to convert ISO 8601 duration to hours
      def self.iso8601_duration_to_hours(duration)
        match = /PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/.match(duration)
        hours = match[1].to_i
        minutes = match[2].to_i / 60.0
        seconds = match[3].to_i / 3600.0
        hours + minutes + seconds
      end
    end
  end
end
