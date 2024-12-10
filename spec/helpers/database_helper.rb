# frozen_string_literal: true

module DatabaseHelper
  def self.wipe_database
    # Ignore foreign key constraints when wiping tables
    RoutePlanner::Api.db.run('PRAGMA foreign_keys = OFF')
    RoutePlanner::Database::OnlineOrm.map(&:destroy)
    RoutePlanner::Database::PhysicalOrm.map(&:destroy)
    RoutePlanner::Api.db.run('PRAGMA foreign_keys = ON')
  end
end
