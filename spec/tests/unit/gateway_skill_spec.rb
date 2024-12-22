# frozen_string_literal: true

require_relative '../../helpers/spec_helper'
require_relative '../../helpers/vcr_helper'

describe 'Tests OpenAI library' do
  before do
    VcrHelper.configure_vcr_for_skill
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Fetch OpenAI skill library successfully' do
    it 'HAPPY: fetches syllabus and analyze prerequisite successfully' do
      skillset = RoutePlanner::OpenAPI::SkillMapper
        .new(SYLLABUS, OPENAI_KEY)
        .call

      _(skillset).must_be_kind_of Array

      skillset.each do |skill|
        _(skill).must_be_kind_of RoutePlanner::Entity::Skill
        _(skill.skill_name).must_be_kind_of String
        _(skill.challenge_score).must_be_kind_of Integer
      end
    end
  end
end
