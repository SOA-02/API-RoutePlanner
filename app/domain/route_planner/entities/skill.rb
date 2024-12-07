# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

# require_relative 'physical'
# require_relative 'online'
module RoutePlanner
  module Entity
    # Domain entity for skill
    class Skill < Dry::Struct
      include Dry.Types()

      attribute :id, Integer.optional
      attribute :map_id, Integer.optional
      attribute :skill_name, Strict::String
      attribute :challenge_score, Strict::Integer

      def to_attr_hash
        to_hash.except(:id)
      end

      def self.gap_ability(desired_resource)
        desired_resource.sum { |key, value| calculate_diff_for_key(key, value) }
      end

      def self.calculate_diff_for_key(key, value)
        record = fetch_skill_score(key)
        record ? calculate_difference(record[:challenge_score], value) : 0
      end

      def self.fetch_skill_score(key)
        Repository::For.klass(Entity::Skill).get_skill_socre(key).first
      end

      def self.calculate_difference(challenge_score, value)
        (challenge_score - value.to_i)
      end
    end
  end
end
