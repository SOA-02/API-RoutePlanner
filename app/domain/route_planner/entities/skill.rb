# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

require_relative 'physical'
require_relative 'online'
module RoutePlanner
  module Entity
    # Domain entity for team members
    class Skill < Dry::Struct
      include Dry.Types()

      attribute :id, Integer.optional
      attribute :skill_name, Strict::String
      attribute :challenge_score, Strict::Integer
      # attribute? :loot_resources, Strict::Array.of(Strict::Hash).optional.default([])

      def to_attr_hash
        to_hash.except(:id)
      end
    end
  end
end

# skill = RoutePlanner::Entity::Skill.new(skill_name: 'Ruby', challenge_level: 30)
# puts skill.skill_name
# puts skill.challenge_level
