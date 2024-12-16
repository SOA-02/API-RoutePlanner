# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  YOUTUBE_CASSETTE = 'youtube_api'
  SUMMARY_CASSETTE = 'summary_openai'
  SKILL_CASSETTE = 'skill_openai'
  NTHUSA_CASSETTE = 'nthusa_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_localhost = true # for acceptance tests
      c.ignore_hosts 'sqs.us-east-1.amazonaws.com'
      c.ignore_hosts 'sqs.ap-northeast-1.amazonaws.com'
    end
  end

  # Unavoidable :reek:TooManyStatements for VCR configuration
  def self.configure_vcr_for_youtube
    VCR.configure do |c|
      c.filter_sensitive_data('<API_KEY>') { API_KEY }
      c.filter_sensitive_data('<API_KEY_ESC>') { CGI.escape(API_KEY) }
      c.filter_sensitive_data('<OPENAI_KEY>') { OPENAI_KEY }
      c.filter_sensitive_data('<OPENAI_KEY_ESC>') { CGI.escape(OPENAI_KEY) }
    end

    VCR.insert_cassette(
      YOUTUBE_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.configure_vcr_for_summary
    VCR.configure do |c|
      c.filter_sensitive_data('<OPENAI_KEY>') { OPENAI_KEY }
      c.filter_sensitive_data('<OPENAI_KEY_ESC>') { CGI.escape(OPENAI_KEY) }
    end

    VCR.insert_cassette(
      SUMMARY_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.configure_vcr_for_skill
    VCR.configure do |c|
      c.filter_sensitive_data('<OPENAI_KEY>') { OPENAI_KEY }
      c.filter_sensitive_data('<OPENAI_KEY_ESC>') { CGI.escape(OPENAI_KEY) }
    end

    VCR.insert_cassette(
      SKILL_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.configure_vcr_for_nthusa
    VCR.configure do |c|
      c.filter_sensitive_data('<OPENAI_KEY>') { OPENAI_KEY }
      c.filter_sensitive_data('<OPENAI_KEY_ESC>') { CGI.escape(OPENAI_KEY) }
    end
    VCR.insert_cassette(
      NTHUSA_CASSETTE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
