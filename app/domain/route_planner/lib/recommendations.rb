# frozen_string_literal: true

module RoutePlanner
  module Mixins
    # Recommendations for skill proficiency
    class Recommendations
      def self.desired_resource(skill_proficiency)
        skill_proficiency.reject { |_key, value| value.to_i > 70 }
      end
    end
  end
end
