# frozen_string_literal: true

require 'rack'
require 'roda'

module RoutePlanner
  # Web API
  class Api < Roda
    plugin :halt
    plugin :json 

    route do |routing|
      response['Content-Type'] = 'application/json'

      # GET /
      routing.root do
        message = "RoutePlanner API v1 at /api/v1/ in #{Api.environment} mode"

        result_response = RoutePlanner::Representer::HttpResponse.new(
          RoutePlanner::APIResponse::ApiResult.new(status: :ok, message:)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end

      routing.on 'api/v1' do
        routing.on 'maps' do
          routing.is do
            # POST /api/v1/maps
            routing.post do
              raw_body = routing.body.read
              raw_body.force_encoding("ASCII-8BIT")
              
              
              raw_body = raw_body.encode("UTF-8", invalid: :replace, undef: :replace, replace: "?")
              
              puts "Raw Body: #{raw_body}"
              parsed_params = JSON.parse(raw_body)
             
               
              result = RoutePlanner::Request::NewMap.new(parsed_params).call
              if result.failure?
                  failed = Representer::HttpResponse.new(result.failure)
                  routing.halt failed.status, failed.to_json
              end

  

              validated_params = result.value!
              service_result = RoutePlanner::Service::AddMapandSkill.new.call(validated_params)
              binding.irb
              if service_result.failure?
                api_result = RoutePlanner::APIResponse::ApiResult.new(
                  status: :bad_request,
                  message: service_result.value!
                 )               

                 http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
                 response.status = http_response.http_status_code
              end


              api_result = RoutePlanner::APIResponse::ApiResult.new(
                    status: :created,
                    message: service_result.value!
              )               

              http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
              response.status = http_response.http_status_code
                  

              RoutePlanner::Representer::AddMapandSkill.new(api_result.message).to_json

            end
          end
          rescue JSON::ParserError
            response.status = 400
            { error: 'Invalid JSON' }.to_json
        end

        routing.on 'RoutePlanner' do
          routing.is do
            # POST /api/v1/RoutePlanner
            routing.post do
              raw_body = routing.body.read
              puts "Raw Body: #{raw_body}"


              parsed_params = JSON.parse(raw_body)
              puts "Parsed Params: #{parsed_params}"

              form_request = RoutePlanner::Request::SkillsForm.new(parsed_params)

              data=RoutePlanner::Service::ProcessUserAbilityValue.new.call(form_request.params)
      
              binding.irb
              if data.failure?
                api_result = RoutePlanner::APIResponse::ApiResult.new(
                  status: :bad_request,
                  message: data.value!
                 )               

                 http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
                 response.status = http_response.http_status_code
              end


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