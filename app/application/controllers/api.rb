# frozen_string_literal: true

require 'rack'
require 'roda'

module RoutePlanner
  # Web App
  class App < Roda
    plugin :halt
    plugin :json 

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "RoutePlanner API v1 at /api/v1/ in #{App.environment} mode"

        result_response = RoutePlanner::Representer::HttpResponse.new(
          RoutePlanner::APIResponse::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      # API Namespace
      routing.on 'api/v1' do
        routing.on 'RoutePlanner' do
          routing.is do
            # POST /api/v1/RoutePlanner
            routing.post do
              raw_body = routing.body.read
              puts "Raw Body: #{raw_body}"

              begin
                parsed_params = JSON.parse(raw_body)
                puts "Parsed Params: #{parsed_params}"

                form_request = RoutePlanner::Request::SkillsForm.new(parsed_params)

                data=RoutePlanner::Service::ProcessUserAbilityValue.new.call(form_request.params)
      
                api_result = RoutePlanner::APIResponse::ApiResult.new(
                    status: :created,
                    message: data.value!
                )
                  

                http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
                response.status = http_response.http_status_code
                  

                RoutePlanner::Representer::StudyStressOutput.new(api_result.message).to_json

              rescue JSON::ParserError => e
                routing.halt 400, { error: "Invalid JSON: #{e.message}" }.to_json
              end
            end
          end

        end
      end
    end
  end
end
