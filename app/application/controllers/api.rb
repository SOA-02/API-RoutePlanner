# frozen_string_literal: true

require 'rack'
require 'roda'

module RoutePlanner
  # Web App
  class App < Roda
    plugin :halt
    plugin :json # 自動處理 JSON 請求與回應

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
                routing.halt 400, { error: form_request.errors.join(', ') }.to_json unless form_request.valid?
                # 直接使用原始的 @params
                session[:skills] = form_request.params
                map = form_request.params.keys.first.split('_skills').first
                results = []
                errors = []
                session[:skills].each_key do |skill|
                  result = Service::AddResources.new.call(online_skill: skill, physical_skill: skill)
                  if result.success?
                    results << result.value!
                  else
                    errors << result.failure
                  end
                end

                if results.any?
                  desired_resource = RoutePlanner::Mixins::Recommendations.desired_resource(session[:skills])
                  results.clear

                  desired_resource.each_value do |skills|
                    binding.irb
                    skills.each_key do |skill|
                      # viewable_resource = Service::FetchViewedResources.new.call(skill)

                      viewable_resource = Service::FetchViewedResources.new.call(skill)
                      binding.irb
                      if viewable_resource.success?
                        results << viewable_resource.value!
                      else
                        errors << viewable_resource.failure
                      end
                    end
                  end

                end

                binding.irb
                if results.any?
                  time = Value::EvaluateStudyStress.compute_minimum_time(results)
                  stress_index = Value::EvaluateStudyStress.evaluate_stress_level(desired_resource, time)

                  {
                    online_resources: results.map { |res| res[:online_resources] }.flatten,
                    physical_resources: results.map { |res| res[:physical_resources] }.flatten,
                    time:,
                    stress_index:
                  }.to_json
                elsif errors.any?
                  routing.halt 500, { error: errors }.to_json
                  routing.halt 500, { error: errors }.to_json
                elsif results.empty?
                  routing.halt 404, { message: 'No resources found' }.to_json
               
                end
                # binding.irb
                # { message: 'Skills processed successfully', redirect_to: "/api/v1/RoutePlanner/#{map}" }.to_json
              rescue JSON::ParserError => e
                routing.halt 400, { error: "Invalid JSON: #{e.message}" }.to_json
              end
            end
          end

          # routing.on String do |map|
          #   # GET /api/v1/RoutePlanner/:map
          #   routing.get do
          #     results = []
          #     errors = []

          #     # Fetch resources for each skill

          #     if results.any?
          #       desired_resource = RoutePlanner::Mixins::Recommendations.desired_resource(session[:skills])
          #       results.clear

          #       desired_resource.each_key do |skill|
          #         viewable_resource = Service::FetchViewedResources.new.call(skill)
          #         if viewable_resource.success?
          #           results << viewable_resource.value!
          #         else
          #           errors << viewable_resource.failure
          #         end
          #       end
          #     end

          #     if errors.any?
          #       routing.halt 500, { error: errors }.to_json
          #     elsif results.empty?
          #       routing.halt 404, { message: 'No resources found' }.to_json
          #     else
          #       time = Value::EvaluateStudyStress.compute_minimum_time(results)
          #       stress_index = Value::EvaluateStudyStress.evaluate_stress_level(desired_resource, time)

          #       {
          #         online_resources: results.map { |res| res[:online_resources] }.flatten,
          #         physical_resources: results.map { |res| res[:physical_resources] }.flatten,
          #         time:,
          #         stress_index:
          #       }.to_json
          #     end
          #   end
          # end
        end
      end
    end
  end
end
