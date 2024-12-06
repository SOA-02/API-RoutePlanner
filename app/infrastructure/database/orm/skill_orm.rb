# frozen_string_literal: true

require 'sequel'

module RoutePlanner
  module Database
    # Object Relational Mapper for Maps
    class SkillOrm < Sequel::Model(:skills)
      many_to_one :map,
                  class: :'RoutePlanner::Database::MapOrm',
                  key: :map_id

      plugin :timestamps, update_on_create: true

      def self.db_find_or_create(skill)
        first(skill_name: skill[:skill_name]) || create(skill)
      end
    end
  end
end
