# frozen_string_literal: true

require 'dry-types'
require 'dry-struct'

module RoutePlanner
  module Entity
    # Domain entity for team members
    class Physical < Dry::Struct
      include Dry.Types

      attribute :id, Integer.optional
      attribute :course_id, Strict::String
      attribute :course_name, Strict::String
      attribute :credit, Strict::Integer
      attribute :language, Strict::String
      attribute :provider, Strict::String
      attribute :timeloc, Strict::String
      attribute :for_skill, Strict::String

      def to_attr_hash
        to_hash.except(:id)
      end

      def self.compute_minimum_time(resources)
        physical_credits = resources.flat_map { |resource| resource[:physical_resources].map(&:credit) }
        compute_physical_time(physical_credits)
      end

      def self.compute_physical_time(physical_credits)
        physical_credits.map { |credit| time_required(credit) }.sum
      end

      def self.time_required(credit)
        credit * 16
      end
    end
  end
end
