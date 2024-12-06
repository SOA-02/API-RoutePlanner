# frozen_string_literal: true

module RoutePlanner
  module Repository
    # Repository for Videos
    class Onlines
      def self.all
        Database::OnlineOrm.all.map { |db_resource| rebuild_entity(db_resource) }
      end

      def self.find_online(entity)
        find_original_id(entity.original_id)
      end

      def self.update_video_duration(original_id, video_duration)
        db_resource = Database::OnlineOrm.first(original_id:)
        db_resource.update(video_duration: video_duration)
      end

      def self.find_all_resource(urls)
        urls.map do |url|
          find_skill(url)
        end.compact
      end

      def self.find_all_resource_of_skills(for_skill)
        db_resources = Database::OnlineOrm.where(for_skill:).all
        db_resources.map { |resource| rebuild_entity(resource) }
      end

      def self.find_skill(for_skill)
        db_resource = Database::OnlineOrm.all(for_skill:)
        rebuild_entity(db_resource)
      end

      def self.find_original_id(original_id)
        db_resource = Database::OnlineOrm.first(original_id:)
        rebuild_entity(db_resource)
      end

      def self.build_online_resource(entity)
        return if find_online(entity)

        db_resource = Database::OnlineOrm.create(entity.to_attr_hash)
        rebuild_entity(db_resource)
      end

      def self.add_to_routeplanner(online_entity, routeplanner_entity)
        # 找到或創建 Online 資源
        online = Database::OnlineOrm.find_or_create(
          original_id: online_entity.original_id,
          topic: online_entity.topic,
          url: online_entity.url,
          platform: online_entity.platform,
          video_duration: online_entity.video_duration,
          for_skill: online_entity.for_skill
        )
      end

      def self.rebuild_entity(db_resource)
        return nil unless db_resource

        Entity::Online.new(
          id: db_resource.id,
          original_id: db_resource.original_id,
          topic: db_resource.topic,
          url: db_resource.url,
          platform: db_resource.platform,
          for_skill: db_resource.for_skill,
          video_duration: db_resource.video_duration
        )
      end

      def initialize(entity)
        @entity = entity
      end
    end
  end
end
