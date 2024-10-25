# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'

require 'minitest/autorun'
require 'minitest/unit' # minitest Github issue #17 requires
require 'minitest/rg'
require 'vcr'
require 'webmock'

# require_relative '../lib/youtube_api'

require_relative '../require_app'
require_app

CHANNEL_ID = 'UCpYf6C9QsP_BRf97vLuXlIA'
VIDEO_ID = 'jeqH4eMGjhY'
API_KEY = Outline::App.config.API_KEY
CORRECT = YAML.safe_load_file('spec/fixtures/youtube_channel_info.yml')

