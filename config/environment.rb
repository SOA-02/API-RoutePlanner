# frozen_string_literal: true

require 'figaro'
require 'rack/session'
require 'roda'
require 'sequel'
require 'yaml'

module RoutePlanner
  # Configuration for the Api
  class Api < Roda
    plugin :environments

    # Environment variables setup
    Figaro.application = Figaro::Application.new(
      environment:,
      path: File.expand_path('config/secrets.yml')
    )
    Figaro.load
    def self.config = Figaro.env

    use Rack::Session::Cookie, secret: config.SESSION_SECRET
    # Database Setup
    configure :development, :test do
      # puts "Database URL: sqlite://#{config.DB_FILENAME}"
      ENV['DATABASE_URL'] = "sqlite://#{config.DB_FILENAME}"
    end

    @db = Sequel.connect(ENV.fetch('DATABASE_URL'))
    def self.db = @db # rubocop:disable Style/TrivialAccessors
  end
end
