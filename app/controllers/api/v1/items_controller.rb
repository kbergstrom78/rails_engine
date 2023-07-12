# frozen_string_literal: true

module Api
  module V1
    class ItemsController < ApplicationController
      def index
        render json: ItemSerializer.new(Item.all)
      end

      def show
        item = Item.find(params[:id])

        if item
          render json: ItemSerializer.new(Item.find(params[:id]))
        else
          render status: 404, json: { error: 'Item not found' }
        end
      end

      def create
        render(status: 201, json: ItemSerializer.new(Item.create(item_params)))
      end

      def update
        item, error_message = Item.update_with_merchant_check(params[:id], params[:item][:merchant_id], item_params)
        if item
          render json: ItemSerializer.new(item)
        else
          render status: 404, json: { error: error_message }
        end
      end

      private

      def item_params
        params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
      end
    end
  end
end
