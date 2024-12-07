# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RoutePlanner
  module Entity
    # Domain entity for map
    class Map < Dry::Struct
      include Dry.Types()

      attribute :id, Integer.optional
      attribute :map_name, Strict::String
      attribute :map_description, Strict::String
      attribute :map_evaluation, Strict::String
      attribute :map_ai, Strict::String

      def to_attr_hash
        to_hash.except(:id)
      end

      def self.evaluate_stress_level(desired_resource, time)
        total_diff = Entity::Skill.gap_ability(desired_resource)
        time_factor = calculate_time_factor(time)
        diff_factor = calculate_diff_factor(total_diff)
        pressure_index = calculate_pressure_index(time_factor, diff_factor)
        stress_level = RoutePlanner::Value::EvaluateStudyStress.determine_stress_level(pressure_index)
        {
          pressure_index: pressure_index,
          stress_level: stress_level
        }
      end

      def self.calculate_time_factor(time)
        normalize_factor((time.to_f / 1000 * 100).round)
      end

      def self.calculate_diff_factor(total_diff)
        normalize_factor(total_diff.abs)
      end

      def self.normalize_factor(value)
        value.clamp(1, 100)
      end

      def self.calculate_pressure_index(time_factor, diff_factor)
        average([time_factor, diff_factor])
      end

      def self.average(values)
        (values.sum / values.size.to_f).round
      end
    end
  end
end
