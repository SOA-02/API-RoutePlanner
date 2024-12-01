# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'

module RoutePlanner
  # Web App
  class App < Roda
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :common_logger, $stderr

    route do |routing|
      response['Content-Type'] = 'text/html; charset=utf-8'
      # GET /
      routing.root do
        message = "RoutePlanner API v1 at /api/v1/ in #{App.environment} mode"

        result_response = RoutePlanner::Representer::HttpResponse.new(
          RoutePlanner::APIResponse::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end


    end
  end
end
