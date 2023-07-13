# frozen_string_literal: true

module Api
  module V1
    class MerchantsController < ApplicationController
      def index
        render json: MerchantSerializer.new(Merchant.all)
      end

      def show
        begin
          merchant = Merchant.find(params[:id])
          render json: MerchantSerializer.new(Merchant.find(params[:id]))
        rescue ActiveRecord::RecordNotFound
          render json: { error: "Couldn't find merchant with 'id'=#{params[:id]}" }, status: :not_found
        end
      end
    end
  end
end
