# frozen_string_literal: true

require 'sequel'

module RoutePlanner
  module Database
    # Object Relational Mapper for Online Entities
    class PhysicalOrm < Sequel::Model(:physicals)
      many_to_one :skills,
                  class: :'RoutePlanner::Database::SkillOrm',
                  key: :skill_name

      plugin :timestamps, update_on_create: true
    end
  end
end
