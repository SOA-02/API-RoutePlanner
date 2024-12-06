# frozen_string_literal: true

require 'sequel'

module RoutePlanner
  module Database
    # Object Relational Mapper for Maps
    class MapOrm < Sequel::Model(:maps)
      one_to_many :skills,
                  class: :'RoutePlanner::Database::SkillOrm',
                  key: :map_id

      plugin :timestamps, update_on_create: true

      def self.db_find_or_create(map)
        first(map_name: map[:map_name]) || create(map)
      end
    end
  end
end
