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
                message = result.value!.message
                result_response = RoutePlanner::Representer::HttpResponse.new(
                  RoutePlanner::APIResponse::ApiResult.new(status: :cannot_process, message:)
                  )
        
                response.status = result_response.http_status_code
                result_response.to_json
              end

  

              validated_params = result.value!
              service_result = RoutePlanner::Service::AddMapandSkill.new.call(validated_params)
              
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
            message = 'Invalid data format'
            result_response = RoutePlanner::Representer::HttpResponse.new(
              RoutePlanner::APIResponse::ApiResult.new(status: :bad_request, message:)
              )
    
            response.status = result_response.http_status_code
            result_response.to_json
        end

        routing.on 'RoutePlanner' do
          routing.is do
            # POST /api/v1/RoutePlanner
            routing.post do
              raw_body = routing.body.read
              puts "Raw Body: #{raw_body}"


              parsed_params = JSON.parse(raw_body)
              puts "Parsed Params: #{parsed_params}"

              form_request = RoutePlanner::Request::SkillsForm.new(parsed_params).call
              
              if form_request.failure?
                api_result = RoutePlanner::APIResponse::ApiResult.new(
                  status: :bad_request,
                  message: form_request.value!
                 )               

                 http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
                 response.status = http_response.http_status_code

              end

              validated_params = form_request.value!

              data=RoutePlanner::Service::ProcessUserAbilityValue.new.call(validated_params)

              if data.failure?
                api_result = RoutePlanner::APIResponse::ApiResult.new(
                  status: :cannot_process,
                  message: data.failure
                 )               
                 http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
                 response.status = http_response.http_status_code
                 routing.halt http_response.to_json

              end


              api_result = RoutePlanner::APIResponse::ApiResult.new(
                    status: :created,
                    message: data.value!
              )               

              http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
              response.status = http_response.http_status_code
                  

              RoutePlanner::Representer::StudyStressOutput.new(api_result.message).to_json

              rescue JSON::ParserError 
                api_result = RoutePlanner::APIResponse::ApiResult.new(
                  status: :bad_request,
                  message: 'Invalid data format'
                 )               

                 http_response = RoutePlanner::Representer::HttpResponse.new(api_result)
                 response.status = http_response.http_status_code
              end

           end

        end
      end
    end
  end
end