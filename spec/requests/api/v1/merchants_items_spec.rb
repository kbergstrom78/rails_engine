# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Merchants API', type: :request do
  describe 'happy path' do
    it 'can get all items from a merchant' do
      id = create(:merchant).id
      create_list(:item, 3, merchant_id: id)

      get "/api/v1/merchants/#{Merchant.first.id}/items"

      expect(response).to be_successful

      items = JSON.parse(response.body, symbolize_names: true)
      expect(items[:data].count).to eq(3)

      items[:data].each do |item|
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
  end

  describe 'sad path' do
    it 'it returns 404 for bad merchant ID when fetching items' do
      get '/api/v1/merchants/-1/items'

      expect(response.status).to eq(404)
      expect(response.body).to match("Couldn't find merchant with 'id'=-1")
    end
  end
end
