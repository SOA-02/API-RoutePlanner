
require 'dry/transaction'

module RoutePlanner
  module Service
    class AddMap
      include Dry::Transaction

      step :validate
      step :find_existing_map
      step :create_entities
      step :store_entities

      def validate(input)
        if input[:syllabus_title] && input[:syllabus_text]
          Success(input)
        else
          Failure('Missing title and text')
        end
      end

      def find_existing_map(input)
        existing_map = Repository::For.klass(Entity::Map)
          .find_map_name(input[:syllabus_title])
        if existing_map
          existing_skills = Repository::For.klass(Entity::Map)
            .find_map_skills(input[:syllabus_title])
          Success(map: existing_map, skills: existing_skills)
        else
          Success(input)
        end
      end

      def create_entities(input)
        return Success(input) if input[:map]

        map = OpenAPI::MapMapper
          .new(input[:syllabus_text], App.config.OPENAI_KEY)
          .call

        skillset = OpenAPI::SkillMapper
          .new(input[:syllabus_text], App.config.OPENAI_KEY)
          .call

        Success(Response::APIResponse.new(
                  status: :created,
                  message: input.merge(map: map, skills: skillset)
                ))
      # rescue OpenAPI::MapperError => e
      #   Failure(Response::ApiResult.new(
      #             status: :cannot_process,
      #             message: 'Failed processing syllabus'
      #           ))
      rescue StandardError => e
        Failure(Response::APIResponse.new(
                  status: :internal_error,
                  message: e.message
                ))
      end

      def store_entities(input)
        return Success(input) if input[:map].id

        Repository::For.entity(input[:map]).build_map(input[:map])

        input[:skills].each do |skill|
          Repository::For.entity(skill).build_skill(skill)
        end

        db_map = Repository::Map.join_map_skill(input[:map], input[:skills])

        Success(Response::APIResponse.new(
                  status: :created,
                  message: { map: db_map, skills: db_map.skills }
                ))
      rescue StandardError => e
        Failure(Response::APIResponse.new(
                  status: :internal_error,
                  message: 'Cannot store planner'
                ))
      end
    end
  end
end
