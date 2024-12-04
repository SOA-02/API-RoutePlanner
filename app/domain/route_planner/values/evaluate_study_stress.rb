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

      def self.evaluate_stress_level(desired_resource, time)
        total_diff = gap_ability(desired_resource)
        time_factor = calculate_time_factor(time)
        diff_factor = calculate_diff_factor(total_diff)
        pressure_index = calculate_pressure_index(time_factor, diff_factor)

        {
          pressure_index: pressure_index,
          stress_level: determine_stress_level(pressure_index)
        }
      end

      class << self
        private

        def gap_ability(desired_resource)
          desired_resource.sum { |key, value| calculate_diff_for_key(key, value) }
        end

        def calculate_diff_for_key(key, value)
          record = fetch_skill_score(key)
          record ? calculate_difference(record[:challenge_score], value) : 0
        end

        def fetch_skill_score(key)
          Repository::For.klass(Entity::Skill).get_skill_socre(key).first
        end

        def calculate_difference(challenge_score, value)
          (challenge_score - value.to_i)
        end

        def calculate_time_factor(time)
          normalize_factor((time.to_f / 1000 * 100).round)
        end

        def calculate_diff_factor(total_diff)
          normalize_factor(total_diff.abs)
        end

        def normalize_factor(value)
          value.clamp(1, 100)
        end

        def calculate_pressure_index(time_factor, diff_factor)
          average([time_factor, diff_factor])
        end

        def average(values)
          (values.sum / values.size.to_f).round
        end

        def determine_stress_level(pressure_index)
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

        def low_stress?(pressure_index)
          pressure_index.between?(1, 30)
        end

        def medium_stress?(pressure_index)
          pressure_index.between?(31, 60)
        end

        def high_stress?(pressure_index)
          pressure_index.between?(61, 100)
        end
      end
    end
  end
end
