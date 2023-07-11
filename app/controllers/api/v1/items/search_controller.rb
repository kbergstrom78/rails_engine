# frozen_string_literal: true

module Api
  module V1
    module Items
      class SearchController < ApplicationController
        def search
          result = Item.find_all(name: params[:name], min_price: params[:min_price], max_price: params[:max_price])
          if result
            render json: ItemSerializer.new(result)
          else
            render json: { error: 'Bad Request' }, status: 404
          end
        end
      end
    end
  end
end
