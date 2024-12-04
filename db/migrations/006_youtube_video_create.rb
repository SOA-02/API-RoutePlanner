# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:youtube_videos) do
      primary_key :id
      foreign_key :online_id, :onlines

      String :video_id, unique: true
      String :video_duration

      DateTime :created_at
      DateTime :updated_at
      index :id
    end
  end
end
