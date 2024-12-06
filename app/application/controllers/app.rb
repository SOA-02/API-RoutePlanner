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
      response['Content-Type'] = 'application/json'
      # GET /
      routing.root do
        message = "RoutePlanner API v1 at /api/v1/ in #{App.environment} mode"

        result_response = RoutePlanner::Representer::HttpResponse.new(
          RoutePlanner::APIResponse::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'map' do
          routing.post do
            # map_param = routing.params['map']

            result = Service::AddMap.new.call(
              syllabus_title: map_param,
              syllabus_text: request.body.read
            )

            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.http_status_code, failed.to_json
            end

            http_response = Representer::HttpResponse.new(result.value!)
            response.status = http_response.http_status_code
            # Representer::Map.new(result.value!).to_json
          end
        end
      end
    end
  end
end
