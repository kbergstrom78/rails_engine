module Api
  module V1
    module Items
      class MerchantController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

        def index
          item = Item.find(params[:item_id])
          merchant = item.merchant
          render json: MerchantSerializer.new(merchant)
        end

        private

        def record_not_found
          render status: 404, json: { error: "Item not Found"}
        end


      end
    end
  end
end