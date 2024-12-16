# frozen_string_literal: true

require 'dry/monads'
require 'json'

module RoutePlanner
  module Request
    # Request value for the syllabus form input
    class NewMap
      include Dry::Monads::Result::Mixin
      INPUTS_REGEX = /\A(?!.*<script>|.*javascript:)[\p{L}\p{N}\p{P}\s]*\p{L}[\p{L}\p{N}\p{P}\s]*\z/
      MSG_INVALID_TITLE = 'Course Title must be filled!'
      MSG_INVALID_TEXT = 'Course Syllabus must be filled!'

      def initialize(params)
        @params = params.transform_keys(&:to_s)
      end

      def call
        validate_inputs
      rescue StandardError => e
        Failure(
          APIResponse::ApiResult.new(
            status: :bad_request,
            message: e.message
          )
        )
      end

      private

      def validate_inputs
        return title_error unless valid_title?
        return text_error unless valid_text?

        Success(
          syllabus_title: @params['syllabus_title'],
          syllabus_text: @params['syllabus_text']
        )
      end

      def valid_title?
        @params['syllabus_title'] && INPUTS_REGEX.match?(@params['syllabus_title'])
      end

      def valid_text?
        @params['syllabus_text'] && !@params['syllabus_text'].strip.empty?
      end

      def title_error
        Failure(
          APIResponse::ApiResult.new(
            status: :bad_request,
            message: MSG_INVALID_TITLE
          )
        )
      end

      def text_error
        Failure(
          APIResponse::ApiResult.new(
            status: :bad_request,
            message: MSG_INVALID_TEXT
          )
        )
      end
    end
  end
end
