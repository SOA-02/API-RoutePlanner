# frozen_string_literal: true

require 'rack' # for Rack::MethodOverride
require 'roda'

module RoutePlanner
  # Web App
  class App < Roda
    css_files = [
      'style.css'
    ]
    plugin :halt
    plugin :flash
    plugin :all_verbs # allows HTTP verbs beyond GET/POST (e.g., DELETE)
    plugin :common_logger, $stderr


    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'text/html; charset=utf-8'
      # GET /
      routing.root do
        # Get cookie viewer's previously seen videos
        # session[:watching] ||= []
        # result = Service::FetchViewedRoadmap.new.call(session[:watching])
        # # watchout
        # if result.failure?
        #   flash[:error] = result.failure
        #   viewable_resource = []
        # else
        #   resourcelist = result.value!
        #   flash.now[:notice] = MSG_GET_STARTED if resourcelist.none?
        #   session[:watching] = resourcelist.map(&:original_id)
        #   viewable_resource = Views::RoadmapsList.new(resourcelist)
        # end
        # view 'home', locals: { roadmaps: viewable_resource }
        #         result_response = Leaf::Representer::HttpResponse.new(
        message = "RoutePlanner API v1 at /api/v1/ in #{App.environment} mode"

        result_response = RoutePlanner::Representer::HttpResponse.new(
          RoutePlanner::APIResponse::ApiResult.new(status: :ok, message: message)
        )

        response.status = result_response.http_status_code
        result_response.to_json
      end
      # routing.on 'search' do
      #   routing.is do
      #     # POST /search/
      #     routing.post do
      #       key_word_request = Forms::NewSearch.new.call(routing.params)
      #       if key_word_request.errors.empty?
      #         key_word = key_word_request[:search_key_word]
      #         routing.redirect "search/#{key_word}"
      #       else
      #         flash[:error] = key_word_request.errors[:search_key_word].first
      #         routing.redirect '/'
      #       end
      #     end
      #   end

      #   routing.on String do |key_word|
      #     # GET /search/key_word
      #     routing.get do
      #       results = Service::SearchService.new.video_from_youtube(key_word)
      #       if results.failure?
      #         flash[:error] = results.failure
      #         routing.redirect '/'
      #       else
      #         @search_results = results.value!
      #         view 'search', locals: { search_results: @search_results }
      #       end
      #     end
      #   end
      # end

      # routing.on 'LevelEvaluation' do
      #   routing.is do
      #     view 'level_eval'
      #   end
      # end

      # routing.on 'RoutePlanner' do
      #   routing.is do
      #     # temp for test

      #     result = Service::AddResources.new.call(key_word: 'C++', pre_req: 'Analytic')
      #     if result.failure?
      #       flash[:error] = result.failure
      #     else
      #       online_resources = Views::OnlineResourceList.new(result.value![:online_resources])
      #       physical_resources = Views::PhyicalResourcesList.new(result.value![:physical_resources])
      #       view 'ability_recs', locals: { online_resources: online_resources, physical_resources: physical_resources }
      #     end
      #     # view 'ability_recs', locals: { online_resources: online_resources }
      #   end
      # end
    end
  end
end