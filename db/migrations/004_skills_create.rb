# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:skills) do
      primary_key :id
      foreign_key :map_id, :maps

      String :skill_name
      Integer :challenge_score

      DateTime :created_at
      DateTime :updated_at
      index :id
    end
  end
end
