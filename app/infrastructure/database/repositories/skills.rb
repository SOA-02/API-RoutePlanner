# frozen_string_literal: true

module RoutePlanner
  module Repository
    # Repository for Skills
    class Skills
      def self.all
        Database::SkillOrm.all.map { |db_resource| rebuild_entity(db_resource) }
      end

      def self.get_skill_socre(skill_name)
        results = Database::SkillOrm.select(:skill_name, :challenge_score).where(skill_name:).all
        results.map { |result| result.values.slice(:skill_name, :challenge_score) }
      end

      def self.find_skillid(id)
        db_resource = Database::SkillOrm.first(id:)
        rebuild_entity(db_resource)
      end

      def self.build_skill(entity)
        db_resource = Database::SkillOrm.create(entity.to_attr_hash)
        rebuild_entity(db_resource)
      end

      def self.rebuild_entity(db_resource)
        return nil unless db_resource

        Entity::Skill.new(
          id: db_resource.id,
          skill_name: db_resource.skill_name,
          challenge_score: db_resource.challenge_score
          # loot_resources: nil
        )
      end
    end
  end
end