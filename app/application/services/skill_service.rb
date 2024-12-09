# frozen_string_literal: true

require 'dry/monads'

module RoutePlanner
  module Service
    # Service to create skillset
    class SkillService
      include Dry::Monads::Result::Mixin
      MSG_NO_SKILL = 'Unable to skillsets for you.'

      def initialize(syllabus_text, openai_key)
        @syllabus_text = syllabus_text
        @openai_key = openai_key
      end

      def call
        skillset = create_skill
        save_skill(skillset)
      end

      def create_skill
        RoutePlanner::OpenAPI::SkillMapper
          .new(@syllabus_text, @openai_key)
          .call
      end

      def save_skill(skillset)
        skillset.each do |skill|
          Repository::For.entity(skill).build_skill(skill)
        end
      end
    end
  end
end
