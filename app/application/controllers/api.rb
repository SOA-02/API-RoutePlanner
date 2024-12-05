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
                user_ability_value = form_request.params
                map = form_request.params.keys.first.split('_skills').first
                results = []
                errors = []
                user_ability_value.each_key do |skill|
                  result = Service::AddResources.new.call(online_skill: skill, physical_skill: skill)
                  if result.success?
                    results << result.value!
                  else
                    errors << result.failure
                  end
                end

                if results.any?
                  desired_resource = RoutePlanner::Mixins::Recommendations.desired_resource(user_ability_value)
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
                  # 計算學習壓力相關值
                  time = Value::EvaluateStudyStress.compute_minimum_time(results)
                  stress_index = Value::EvaluateStudyStress.evaluate_stress_level(desired_resource, time)
                
                  # 準備輸出資料
                  output_data = OpenStruct.new(
                    map: map,
                    user_ability_value: user_ability_value,
                    time: time,
                    stress_index: stress_index,
                    online_resources: results.map { |res| res[:online_resources] }.flatten,
                    physical_resources: results.map { |res| res[:physical_resources] }.flatten
                  )
                
                  # 使用 Representer 將資料轉為 JSON 格式
                  response.status = 200
                  Representer::StudyStressOutput.new(output_data).to_json
                elsif errors.any?
                  response.status = 500
                  { error: errors }.to_json
                elsif results.empty?
                  response.status = 404
                  { message: 'No resources found' }.to_json
                end

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
          #       desired_resource = RoutePlanner::Mixins::Recommendations.desired_resource(user_ability_value)
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
