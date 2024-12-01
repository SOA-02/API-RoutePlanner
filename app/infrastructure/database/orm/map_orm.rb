# frozen_string_literal: true

require 'sequel'

module RoutePlanner
  module Database
    # Object Relational Mapper for Maps
    class MapOrm < Sequel::Model(:maps)
      one_to_many :map_skills,
                  class: :'RoutePlanner::Database::MapSkillOrm',
                  key: :map_id

      many_to_many :skills,
                   class: :'RoutePlanner::Database::SkillOrm',
                   join_table: :map_skills,
                   left_key: :map_id, right_key: :skill_id

      plugin :timestamps, update_on_create: true

      def self.db_find_or_create(map)
        first(map_name: map[:map_name]) || create(map)
      end
    end
  end
end