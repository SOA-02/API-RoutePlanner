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
    plugin :json
    plugin :json_parser

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
        routing.on 'maps' do
          routing.post do
            params = if request.content_type =~ /json/i
                       JSON.parse(request.body.read)
                     else
                       routing.params
                     end
  
            form_request = RoutePlanner::Request::NewMap.new(params)
            result = form_request.call
  
            if result.failure?
              failed = Representer::HttpResponse.new(result.failure)
              routing.halt failed.status, failed.to_json
            else
              validated_params = result.value!
              add_map_service = RoutePlanner::Service::AddMap.new
              service_result = add_map_service.call(validated_params)
  
              if service_result.failure?
                failed = RoutePlanner::Representer::HttpResponse.new(service_result.failure)
                routing.halt failed.status, failed.to_json
              else
                map_entity = service_result.value![:map]
                skills_entities = service_result.value![:skills]
  
                map = RoutePlanner::Representer::Map.new(map_entity).to_json
                skills = skills_entities.map { |skill| RoutePlanner::Representer::Skill.new(skill).to_json }
  
                response.status = 201
                { message: 'Syllabus processed successfully', map: map, skills: skills }.to_json
              end
            end
          rescue JSON::ParserError
            response.status = 400
            { error: 'Invalid JSON' }.to_json
          end
        end
      end
    end
  end
end
