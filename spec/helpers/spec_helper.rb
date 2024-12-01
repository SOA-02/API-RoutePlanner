# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'simplecov'
SimpleCov.start

require 'yaml'
require 'minitest/autorun'
require 'minitest/unit'
require 'minitest/rg'
require 'vcr'
require 'webmock'

require_relative '../../require_app'

require_app

CHANNEL_ID = 'UCpYf6C9QsP_BRf97vLuXlIA'
VIDEO_ID = 'xiWUL3M9D8c'
KEY_WORD = 'Ruby'
SKILL = 'Analytic'
API_KEY = RoutePlanner::App.config.API_KEY
OPENAI_KEY = RoutePlanner::App.config.OPENAI_KEY
SYLLABUS = File.read(File.expand_path('../fixtures/syllabus_example.txt', __dir__))
CORRECT = YAML.safe_load_file('spec/fixtures/youtube_channel_info.yml')
