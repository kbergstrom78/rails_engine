# frozen_string_literal: true

module Api
  module V1
    module Merchants
      class ItemsController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
        def index
          render json: ItemSerializer.new(MerchantItemsFacade.find_by_merch_id(params[:merchant_id]))
        end

        private

        def record_not_found
          render json: { error: "Couldn't find merchant with 'id'=#{params[:merchant_id]}" }, status: :not_found
        end
      end
    end
  end
end
