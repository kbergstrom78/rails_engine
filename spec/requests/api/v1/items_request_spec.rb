# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe 'Items API' do
  describe 'happy path' do
    it 'sends a list of items' do
      id_1 = create(:merchant).id
      id_2 = create(:merchant).id
      create_list(:item, 4, merchant_id: id_1)
      create_list(:item, 4, merchant_id: id_2)

      get '/api/v1/items'

      items_info = JSON.parse(response.body, symbolize_names: true)
      items = items_info[:data]

      expect(response).to be_successful

      items.each do |item|
        expect(item[:attributes]).to have_key(:name)
        expect(item[:attributes][:name]).to be_a(String)
        expect(item[:attributes]).to have_key(:description)
        expect(item[:attributes][:description]).to be_a(String)
        expect(item[:attributes]).to have_key(:unit_price)
        expect(item[:attributes][:unit_price]).to be_a(Float)
        expect(item[:attributes]).to have_key(:merchant_id)
        expect(item[:attributes][:merchant_id]).to be_a(Integer)
      end
    end

    it 'can get one item by its id' do
      create(:merchant)
      id = create(:item, merchant_id: create(:merchant).id).id

      get api_v1_item_path(id)

      item_info = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful

      expect(item_info[:data]).to have_key(:id)
      expect(item_info[:data][:id]).to eq(id.to_s)
      expect(item_info[:data][:attributes]).to have_key(:name)
      expect(item_info[:data][:attributes][:name]).to be_a(String)
      expect(item_info[:data][:attributes]).to have_key(:description)
      expect(item_info[:data][:attributes][:description]).to be_a(String)
      expect(item_info[:data][:attributes]).to have_key(:unit_price)
      expect(item_info[:data][:attributes][:unit_price]).to be_a(Float)
      expect(item_info[:data][:attributes]).to have_key(:merchant_id)
      expect(item_info[:data][:attributes][:merchant_id]).to be_a(Integer)
    end
  end
end
