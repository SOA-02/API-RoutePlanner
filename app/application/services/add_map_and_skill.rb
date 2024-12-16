# frozen_string_literal: true

require 'dry/transaction'

module RoutePlanner
  module Service
    # The AddMapandSkill class is responsible for managing and adding maps and skills
    class AddMapandSkill
      include Dry::Transaction
      MSG_SERVER_ERROR = 'An unexpected error occurred on the server. Please try again later.'
      MSG_ONPENAPI_ERROR = 'Could not analyze the syllabus text. Please try again later.'
      MSG_MAP_SAVE_FAIL = 'Map could not be saved.'
      MSG_SKILL_SAVE_FAIL = 'Skills could not be saved.'
      PROCESSING_MSG = 'Map is being processed. Please try again later.'
      CLONE_ERR = 'Could not clone this project'

      step :find_existing_map
      step :enqueue_analysis_worker
      step :store_mapinfo_and_skills

      def find_existing_map(input)
        if (existing_map = map_in_database(input[:syllabus_title]))
          map = existing_map
          skills = skills_in_database(existing_map.id)
        else
          map = analyze_map_from_openai(input[:syllabus_text])
          skills = []
        end
        Success(input.merge(map: map, skills: skills))
      rescue StandardError
        Failure(MSG_SERVER_ERROR)
      end

      def store_mapinfo_and_skills(input)
        if input[:skills].empty?
          result = store_map(input[:map])
          id = result[:map_id]
          process_and_store_skills(input[:syllabus_text], id, input)
        end
        Success(OpenStruct.new({ map: input[:map], skills: input[:skills] }))
      end

      def map_in_database(map_name)
        Repository::For.klass(Entity::Map).find_map_name(map_name)
      end

      def analyze_map_from_openai(syllabus_text)
        OpenAPI::MapMapper.new(syllabus_text, Api.config.OPENAI_KEY).call
      rescue StandardError
        Failure(MSG_ONPENAPI_ERROR)
      end

      def store_map(map)
        Repository::For.klass(Entity::Map).build_map(map)
      rescue StandardError
        Failure(MSG_MAP_SAVE_FAIL)
      end

      def process_and_store_skills(syllabus_text, id, input)
        fetch_skills(syllabus_text).each do |skill|
          unless skill.nil?
            store_skills(skill, id)
            input[:skills] << skill.skill_name
          end
        end
      end

      def fetch_skills(syllabus_text)
        OpenAPI::SkillMapper.new(syllabus_text, Api.config.OPENAI_KEY).call
      rescue StandardError
        Failure(MSG_ONPENAPI_ERROR)
      end

      def store_skills(skill, id)
        Repository::For.klass(Entity::Skill).build_skill(skill, id)
      rescue StandardError
        Failure(MSG_SKILL_SAVE_FAIL)
      end

      def skills_in_database(map_id)
        Repository::For.klass(Entity::Skill).find_all_skills(map_id)
      end
    end
  end
end
