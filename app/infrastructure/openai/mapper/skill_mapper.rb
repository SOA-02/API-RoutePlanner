# frozen_string_literal: true

module RoutePlanner
  module OpenAPI
    # map main quest to entity
    class SkillMapper
      def initialize(input, openai_key, prompt = skill_prompt, gateway_class = ChatService)
        @input = input
        @openai_key = openai_key
        @prompt = prompt
        @gateway_class = gateway_class
        @gateway = build_gateway
      end

      def call
        skillset = @gateway.call
        skill = parse_response(skillset)
        build_entity(skill)
      end

      def skill_prompt
        RoutePlanner::Value::Prompt.new.skill_prompt
      end

      def build_gateway
        @gateway_class.new(
          input: @input,
          prompt: @prompt,
          api_key: @openai_key
        )
      end

      def parse_response(response)
        response.gsub(/^```json\n|```$/m, '')
        JSON.parse(response)
        # puts parsed['prerequisite_subjects'][0]
      end

      def build_entity(response)
        DataMapper.new(response).build_entity
      end

      # map entities to domain object
      class DataMapper
        def initialize(parsed_response)
          @parsed_response = parsed_response
        end

        def build_entity
          @parsed_response['prerequisite_subjects'].map do |subject|
            RoutePlanner::Entity::Skill.new(
              id: nil,
              map_id: nil,
              skill_name: subject['SubjectName'],
              challenge_score: subject['DifficultyLevel']
            )
          end
        end
      end
    end
  end
end
