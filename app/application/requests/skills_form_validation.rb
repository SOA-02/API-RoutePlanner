# frozen_string_literal: true

require 'dry/monads'
require 'json'

module RoutePlanner
  module Request
    # Application value for the skills form input
    class SkillsForm
      include Dry::Monads[:result]

      VALID_SKILL_VALUES = (1..100)
      MSG_INVALID_SKILL_VALUE = 'Skill value must be an integer between ' \
                                "#{VALID_SKILL_VALUES.first} and #{VALID_SKILL_VALUES.last}.".freeze
      MSG_EMPTY_SKILLS = 'Skills cannot be empty and must contain at least one valid skill with a value.'

      def initialize(params)
        @params = params
      end

      attr_reader :params

      def call
        validate_inputs
      end

      # Main validation method to return Success or Failure
      def validate_inputs
        if valid?
          Success(params)
        else
          Failure(errors)
        end
      end

      def valid?
        errors.empty?
      end

      def errors
        @errors ||= validate_skills
      end

      private

      def validate_skills
        return [MSG_EMPTY_SKILLS] if invalid_params?

        @params.each_with_object([]) do |(group_key, skills_hash), errors|
          errors.concat(validate_group(group_key, skills_hash))
        end
      end

      def invalid_params?
        @params.nil? || @params.empty?
      end

      def validate_group(group_key, skills_hash)
        return ["#{group_key}: #{MSG_EMPTY_SKILLS}"] unless valid_group?(group_key, skills_hash)

        validate_skills_in_group(skills_hash)
      end

      def valid_group?(group_key, skills_hash)
        group_key.include?('_skills') && skills_hash.is_a?(Hash) && !skills_hash.empty?
      end

      def validate_skills_in_group(skills_hash)
        skills_hash.each_with_object([]) do |(skill_name, skill_value), errors|
          errors << "#{skill_name}: #{MSG_INVALID_SKILL_VALUE}" unless valid_skill_value?(skill_value)

          # Normalize skill value to integer
          skills_hash[skill_name] = skill_value.to_i
        end
      end

      def valid_skill_value?(value)
        numeric_value = value.to_i
        (value == '0' || numeric_value.positive?) && VALID_SKILL_VALUES.include?(numeric_value)
      end
    end
  end
end
