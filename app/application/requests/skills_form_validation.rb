# frozen_string_literal: true

module RoutePlanner
  module Request
    # Application value for the skills form input
    class SkillsForm
      VALID_SKILL_VALUES = (1..100)
      MSG_INVALID_SKILL_VALUE = "Skill value must be an integer between #{VALID_SKILL_VALUES.first} and #{VALID_SKILL_VALUES.last}.".freeze

      def initialize(params)
        @params = params
      end

      attr_reader :params

      def valid?
        @validation_result ||= validate_skills
        @validation_result.empty?
      end

      def errors
        @validation_result || validate_skills
      end

      private

      def validate_skills
        errors = []
        @params.each do |group_key, skills_hash|
          next unless group_key.include?('_skills')

          skills_hash.each do |skill_name, skill_value|
            numeric_value = skill_value.to_i
            errors << "#{skill_name}: #{MSG_INVALID_SKILL_VALUE}" unless VALID_SKILL_VALUES.include?(numeric_value)

            # 更新技能值為數字形式
            skills_hash[skill_name] = numeric_value
          end
        end
        errors
      end
    end
  end
end
