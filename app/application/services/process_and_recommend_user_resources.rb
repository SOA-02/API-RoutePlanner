# frozen_string_literal: true

require 'dry/transaction'

module RoutePlanner
  module Service
    # Process user abilities and recommend resources
    class ProcessUserAbilityValue
      include Dry::Transaction

      MSG_NO_SKILLS_PROVIDED = 'No skills provided in the input'
      MSG_NO_RECOMMENDED_RESOURCES = 'No recommended resources found'
      MSG_PROCESSING_ERROR = 'An unexpected error occurred during processing'

      step :validate_input
      step :process_user_skills
      step :fetch_map_skills
      step :recommend_resources
      step :calculate_study_metrics

      private

      # Step 1: Validate input parameters
      def validate_input(params)
        return Failure(MSG_NO_SKILLS_PROVIDED) if params.empty?

        user_ability_value = params
        map = params.keys.first.split('_skills').first

        Success(map: map, user_ability_value: user_ability_value)
      rescue StandardError
        Failure("step1#{MSG_NO_RECOMMENDED_RESOURCES}")
      end

      # Step 2: Process user skills
      def process_user_skills(input) # rubocop:disable Metrics/MethodLength
        user_ability_value = input[:user_ability_value]

        results = []
        errors = []

        user_ability_value.each_value do |skills|
          skills.each_key do |skill|
            result = Service::AddResources.new.call(online_skill: skill, physical_skill: skill)
            if result.success?
              results << result.success
            else
              errors << result.failure
            end
          end
        end

        if results.empty?
          Failure(errors:)
        else
          Success(input)
        end
      rescue StandardError
        Failure("step2#{MSG_NO_RECOMMENDED_RESOURCES}")
      end

      # Step 3: Fetch map skills by map name
      def fetch_map_skills(input)
        map_name = input[:map]

        result = Service::FetchMapSkillRequire.new.call(map_name)

        return Failure("step3#{MSG_NO_RECOMMENDED_RESOURCES}") unless result.success?

        # Merge the fetched map skills into the input
        Success(input.merge(map_skills: result.success))
      rescue StandardError
        Failure("step3#{MSG_PROCESSING_ERROR}")
      end

      # Step 4: Recommend resources based on user skills
      def recommend_resources(input) # rubocop:disable Metrics/MethodLength
        desired_resource = RoutePlanner::Mixins::Recommendations.desired_resource(input[:user_ability_value])
        recommended_resources = []
        desired_resource.each_value do |skills|
          skills.each_key do |skill|
            viewable_resource = Service::FetchViewedResources.new.call(skill)
            recommended_resources << viewable_resource.value! if viewable_resource.success?
          end
        end
        if recommended_resources.empty?
          Failure("step4#{MSG_NO_RECOMMENDED_RESOURCES}")
        else
          Success(input.merge(recommended_resources:))
        end
      rescue StandardError
        Failure(MSG_PROCESSING_ERROR)
      end

      # Step 5: Calculate study metrics
      def calculate_study_metrics(input) # rubocop:disable Metrics/MethodLength
        recommended_resources = input[:recommended_resources]
        desired_resource = input[:user_ability_value]

        time = Value::EvaluateStudyStress.compute_minimum_time(recommended_resources)
        stress_index = Value::EvaluateStudyStress.evaluate_stress_level(desired_resource, time)
        output_data = OpenStruct.new(
          map: input[:map],
          map_skills: input[:map_skills],
          user_ability_value: input[:user_ability_value],
          time: time,
          stress_index: stress_index,
          online_resources: recommended_resources.map { |res| res[:online_resources] }.flatten,
          physical_resources: recommended_resources.map { |res| res[:physical_resources] }.flatten
        )

        Success(output_data)
      rescue StandardError
        Failure("step5#{MSG_NO_RECOMMENDED_RESOURCES}")
      end
    end
  end
end
