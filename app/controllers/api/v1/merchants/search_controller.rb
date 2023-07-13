module Api
  module V1
    module Merchants
      class SearchController < ApplicationController
        def search
          if params[:name].present?
            merchants = Merchant.search_by_name(params[:name])
            if merchants.empty?
              render json: { data: [] }, status: 200
            else
              render json: MerchantSerializer.new(merchants.first).serializable_hash.to_json
            end
          else
            render json: { data: [] }, status: 200
          end
        end
      end
    end
  end
end


