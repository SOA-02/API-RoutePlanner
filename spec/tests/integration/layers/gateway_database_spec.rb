# frozen_string_literal: false

require_relative '../../../helpers/spec_helper'
require_relative '../../../helpers/vcr_helper'
require_relative '../../../helpers/database_helper'

describe 'Integration Tests of Youtube API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_youtube
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store videos' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: save yt api to database' do
      videos = RoutePlanner::Youtube::VideoRecommendMapper.new(API_KEY).find(KEY_WORD)
      _(videos).wont_be_empty
      _(videos).must_be_kind_of Array
      videos.each do |video|
        RoutePlanner::Repository::For.entity(video).build_online_resource(video) if video.id.nil?

        rebuilt = RoutePlanner::Repository::For.entity(video).find_online(video)
        _(rebuilt).wont_be_nil

        _(rebuilt.topic).wont_be_nil
        _(rebuilt.url).wont_be_nil
        _(rebuilt.platform).wont_be_nil
      end
    end
  end
end

describe 'Integration Tests of NTHUSA API and Database' do
  VcrHelper.setup_vcr

  before do
    VcrHelper.configure_vcr_for_nthusa
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Retrieve and store courses' do
    before do
      DatabaseHelper.wipe_database
    end

    it 'HAPPY: save nthusa api to database' do
      courses = RoutePlanner::Nthusa::PhysicalRecommendMapper.new.find(SKILL)
      _(courses).wont_be_empty
      _(courses).must_be_kind_of Array
      courses.each do |course|
        RoutePlanner::Repository::For.entity(course).build_physical_resource(course) if course.id.nil?

        rebuilt = RoutePlanner::Repository::For.entity(course).physicals_find(course)
        _(rebuilt).wont_be_nil

        _(rebuilt.course_id).wont_be_nil
        _(rebuilt.course_name).wont_be_nil
        _(rebuilt.credit).wont_be_nil
      end
    end
  end
end

describe 'Tests OpenAI Syllabus' do
  VcrHelper.setup_vcr
  before do
    VcrHelper.configure_vcr_for_summary
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Fetch OpenAI successfully' do
    before do
      @summary = RoutePlanner::OpenAPI::MapMapper
        .new(SYLLABUS, OPENAI_KEY)
        .call

      @skillset = RoutePlanner::OpenAPI::SkillMapper
        .new(SYLLABUS, OPENAI_KEY)
        .call

      @rebuilt = RoutePlanner::Repository::For.entity(@summary).build_map(@summary)
    end
    it 'HAPPY: fetch summary response from openai' do
      _(@summary).must_be_kind_of RoutePlanner::Entity::Map

      _(@rebuilt.map_name).must_be_kind_of String
      _(@rebuilt.map_description).must_be_kind_of String
      _(@rebuilt.map_evaluation).must_be_kind_of String
      _(@rebuilt.map_ai).must_be_kind_of String
    end

    it 'HAPPY: find a map by name' do
      result = RoutePlanner::Repository::For.klass(RoutePlanner::Entity::Map)
        .find_map_name(@rebuilt.map_name)

      _(result.map_name).must_equal 'Business Analytics using Machine Learning'
    end

    it 'find skills associated with a map' do
      result = RoutePlanner::Repository::For.klass(RoutePlanner::Entity::Map)
        .find_map_skills(@rebuilt.map_name)

      _(result).must_be_kind_of Array

      result.each do |skill|
        _(skill).must_be_kind_of RoutePlanner::Entity::Skill
      end
    end
    it 'HAPPY: label map to skills' do
      db_map = RoutePlanner::Database::MapOrm.db_find_or_create(@summary.to_attr_hash)

      @skillset.each do |skill|
        db_skill = RoutePlanner::Database::SkillOrm.db_find_or_create(skill.to_attr_hash)
        db_map.add_skill(db_skill)

        # Verify the association
        _(db_map.skills).must_include db_skill
        _(db_skill.maps).must_include db_map
      end
    end
    it 'HAPPY: join_map_skill method is working' do
      join = RoutePlanner::Repository::MapSkills.join_map_skill(@summary, @skillset)
      _(join.skills).must_be_kind_of Array

      join.skills.each do |skill|
        _(skill).must_be_kind_of RoutePlanner::Database::SkillOrm
        _(skill.skill_name).must_be_kind_of String
        _(skill.challenge_score).must_be_kind_of Integer
      end
    end
  end
end

describe 'Tests OpenAI Skillset' do
  VcrHelper.setup_vcr
  before do
    VcrHelper.configure_vcr_for_skill
  end

  after do
    VcrHelper.eject_vcr
  end

  describe 'Fetch OpenAI successfully' do
    it 'HAPPY: fetches syllabus and analyze prerequisite successfully' do
      skillset = RoutePlanner::OpenAPI::SkillMapper
        .new(SYLLABUS, OPENAI_KEY)
        .call

      _(skillset).must_be_kind_of Array

      skillset.each do |skill|
        _(skill).must_be_kind_of RoutePlanner::Entity::Skill
        rebuilt = RoutePlanner::Repository::For.entity(skill).build_skill(skill)
        _(rebuilt.skill_name).must_be_kind_of String
        _(rebuilt.challenge_score).must_be_kind_of Integer
      end
    end
  end
end
