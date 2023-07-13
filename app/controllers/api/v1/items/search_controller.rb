module Api
  module V1
    module Items
      class SearchController < ApplicationController
        def search
          fragment = params[:name]
          min_price = params[:min_price]
          max_price = params[:max_price]

          if fragment.blank? && min_price.blank? && max_price.blank?
            render json: { errors: 'Bad Request' }, status: 404
          elsif fragment.present? && (min_price.present? || max_price.present?)
            render json: { errors: 'Cannot send name and price parameters together' }, status: 400
          elsif min_price.to_f < 0 || max_price.to_f < 0
            render json: { errors: 'Price must be greater than or equal to 0' }, status: 400
          else
            result = Item.find_all(name: fragment, min_price: min_price, max_price: max_price)
            if result.empty?
              render json: { data: [] }, status: 200
            elsif result
              render json: ItemSerializer.new(result)
            else
              render json: { errors: 'Bad Request' }, status: 400
            end
          end
        end
      end
    end
  end
end



