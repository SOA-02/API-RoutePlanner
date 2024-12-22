# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'
task :default do
  puts `rake -T`
end

namespace :spec do
  desc 'Run unit and integration tests'
  Rake::TestTask.new(:default) do |t|
    puts 'Make sure worker is running in separate process'
    t.pattern = 'spec/tests/{integration,unit}/**/*_spec.rb'
    t.warning = false
  end

  # NOTE: make sure you have run `rake run:test` in another process
  desc 'Run acceptance tests'
  Rake::TestTask.new(:acceptance) do |t|
    t.pattern = 'spec/tests/acceptance/*_spec.rb'
    t.warning = false
  end

  desc 'Run unit, integration, and acceptance tests'
  Rake::TestTask.new(:all) do |t|
    t.pattern = 'spec/tests/**/*_spec.rb'
    t.warning = false
  end
end

desc 'Keep rerunning unit/integration tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*' --ignore 'repostore/*'"
end

desc 'Run web app in default mode'
task run: ['run:default']

namespace :run do
  desc 'Run web app in development or production'
  task :dev do
    sh 'bundle exec puma -p 9090'
  end

  desc 'Run web app for acceptance tests'
  task :test do
    sh 'RACK_ENV=test puma -p 9000'
  end
end

desc 'Keep rerunning web app upon changes'
task :rerun do
  sh "rerun -c --ignore 'coverage/*' --ignore 'repostore/*' -- bundle exec puma"
end

desc 'Generates a 64-byte secret for Rack::Session'
task :new_session_secret do
  require 'base64'
  require 'securerandom' # Corrected capitalization here
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(_1) }
  puts "SESSION_SECRET: #{secret}"
end

namespace :db do
  task :config do # rubocop:disable Rake/Desc
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = RoutePlanner::Api # rubocop:disable Rake/MethodDefinitionInTask
  end

  desc 'Run migration'
  task migrate: :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task wipe: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app(%w[domain infrastructure])
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task drop: :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(RoutePlanner::Api.config.DB_FILENAME)
    puts "Deleted #{RoutePlanner::Api.config.DB_FILENAME}"
  end
end

namespace :repos do
  task :config do # rubocop:disable Rake/Desc
    require_relative 'config/environment' # load config info
    def app = CodePraise::Api # rubocop:disable Rake/MethodDefinitionInTask
    @repo_dirs = Dir.glob("#{app.config.REPOSTORE_PATH}/*/")
  end

  desc 'Create directory for repo store'
  task :create => :config do
    puts `mkdir #{app.config.REPOSTORE_PATH}`
  end

  desc 'Delete cloned repos in repo store'
  task :wipe => :config do
    puts 'No git repositories found in repostore' if @repo_dirs.empty?

    sh "rm -rf #{app.config.REPOSTORE_PATH}/*/" do |ok, _|
      puts(ok ? "#{@repo_dirs.count} repos deleted" : 'Could not delete repos')
    end
  end

  desc 'List cloned repos in repo store'
  task :list => :config do
    if @repo_dirs.empty?
      puts 'No git repositories found in repostore'
    else
      puts @repo_dirs.join("\n")
    end
  end
end

namespace :queues do
  task :config do # rubocop:disable Rake/Desc
    require 'aws-sdk-sqs'
    require_relative 'config/environment' # load config info
    @api = RoutePlanner::Api
    @sqs = Aws::SQS::Client.new(
      access_key_id: @api.config.AWS_ACCESS_KEY_ID,
      secret_access_key: @api.config.AWS_SECRET_ACCESS_KEY,
      region: @api.config.AWS_REGION
    )
    @q_name = @api.config.CLONE_QUEUE
    @q_url = @sqs.get_queue_url(queue_name: @q_name).queue_url

    puts "Environment: #{@api.environment}"
  end

  desc 'Create SQS queue for worker'
  task :create => :config do
    @sqs.create_queue(queue_name: @q_name)

    puts 'Queue created:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error creating queue: #{e}"
  end

  desc 'Report status of queue for worker'
  task :status => :config do
    puts 'Queue status:'
    puts "  Name: #{@q_name}"
    puts "  Region: #{@api.config.AWS_REGION}"
    puts "  URL: #{@q_url}"
  rescue StandardError => e
    puts "Error getting queue status: #{e}"
  end

  desc 'Purge messages in SQS queue for worker'
  task :purge => :config do
    @sqs.purge_queue(queue_url: @q_url)
    puts "Queue #{@q_name} purged"
  rescue StandardError => e
    puts "Error purging queue: #{e}"
  end
end

namespace :workers do
  namespace :run do
    desc 'Run the background analysis worker in development mode'
    task :dev => :config do
      sh 'RACK_ENV=development bundle exec shoryuken -r ./workers/analysis_worker.rb -C ./workers/shoryuken_dev.yml'
    end

    desc 'Run the background analysis worker in test mode'
    task :test => :config do
      sh 'RACK_ENV=test bundle exec shoryuken -r ./workers/analysis_worker.rb -C ./workers/shoryuken_test.yml'
    end

    desc 'Run the background analysis worker in production mode'
    task :production => :config do
      'RACK_ENV=production bundle exec shoryuken -r ./workers/analysis_worker.rb -C ./workers/shoryuken.yml'
    end
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'complexiy analysis'
  task :flog do
    sh "flog -m #{only_app}"
  end
end
