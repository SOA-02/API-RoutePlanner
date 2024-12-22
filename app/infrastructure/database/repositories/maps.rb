# frozen_string_literal: true

module RoutePlanner
  module Repository
    # Repository for Maps
    class Maps
      def self.all
        Database::MapOrm.all.map { |db_resource| rebuild_entity(db_resource) }
      end

      def self.find_mapid(map_name)
        map = Database::MapOrm.where(map_name:).select(:id).first
        map.id
      end

      def self.find_id(id)
        db_resource = Database::MapOrm.first(id:)
        rebuild_entity(db_resource)
      end

      def self.find_map_name(map_name)
        db_resource = Database::MapOrm.first(map_name: map_name)
        rebuild_entity(db_resource)
      end

      def self.find_map_skills(map_name)
        db_resource = Database::MapOrm.first(map_name: map_name)
        # db_resource.skills >> Type: Database::SkillOrm
        db_resource.skills.map { |db_skill| Skills.rebuild_entity(db_skill) }
      end

      def self.join_map_skill(map_entity, skillset_entity)
        db_map = Database::MapOrm.db_find_or_create(map_entity.to_attr_hash)

        skillset_entity.each do |skill|
          db_skill = Database::SkillOrm.db_find_or_create(skill.to_attr_hash)
          db_map.add_skill(db_skill)
        end
        db_map
      end

      def self.build_map(entity)
        db_resource = Database::MapOrm.db_find_or_create(entity.to_attr_hash)
        { map_id: db_resource.id, map_entity: rebuild_entity(db_resource) }
      end

      def self.rebuild_entity(db_resource)
        return nil unless db_resource

        Entity::Map.new(
          id: db_resource.id,
          map_name: db_resource.map_name,
          map_description: db_resource.map_description,
          map_evaluation: db_resource.map_evaluation,
          map_ai: db_resource.map_ai
        )
      end

      def self.db_find_or_create(map_entity)
        Database::MapOrm.db_find_or_create(map_entity.to_attr_hash)
      end
    end
  end
end
