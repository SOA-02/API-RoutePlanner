# frozen_string_literal: true

module RoutePlanner
  module Value
    # Calculate stress level based on study time and ability gap
    class EvaluateStudyStress
      attr_reader :min_time

      def self.compute_minimum_time(resources)
        total_physical_time = Entity::Physical.compute_minimum_time(resources)
        total_online_time =   Entity::Online.compute_minimum_time(resources)

        total_online_time + total_physical_time
      end

      def self.determine_stress_level(pressure_index)
        if low_stress?(pressure_index)
          'Low'
        elsif medium_stress?(pressure_index)
          'Medium'
        elsif high_stress?(pressure_index)
          'High'
        else
          'Unknown'
        end
      end

      def self.low_stress?(pressure_index)
        result = pressure_index.between?(1, 30)
        puts 'Low stress' if result
        result
      end

      def self.medium_stress?(pressure_index)
        result = pressure_index.between?(31, 60)
        puts 'Medium stress' if result
        result
      end

      def self.high_stress?(pressure_index)
        result = pressure_index.between?(61, 100)
        puts 'High stress' if result
        result
      end
    end
  end
end
