# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:onlines) do
      primary_key :id

      String :original_id, unique: true
      String :topic
      String :url, unique: true
      String :platform
      String :video_duration
      String :for_skill

      DateTime :created_at
      DateTime :updated_at
      index :id
    end
  end
end
