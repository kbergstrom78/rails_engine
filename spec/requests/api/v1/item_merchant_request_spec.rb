require 'rails_helper'

RSpec.describe 'Item Merchant API', type: :request do
  describe 'happy path' do
    it 'can get the merchant for an item' do
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      @merchant3 = create(:merchant)
      @item = create(:item, merchant: @merchant)

      get api_v1_item_merchant_index_path(@item)

      expect(response).to be_successful

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data[:data][:attributes]).to have_key(:name)
      expect(merchant_data[:data][:attributes][:name]).to eq(@merchant.name)
      expect(merchant_data[:data][:attributes][:name]).to_not eq(@merchant2.name)
      expect(merchant_data[:data][:attributes][:name]).to_not eq(@merchant3.name)
    end
  end

  describe 'sad path' do
    it 'returns 404 for bad item id when trying to access its merchant' do
      get "/api/v1/items/-1/merchant"

      expect(response.status).to eq(404)
      expect(response.body).to eq("{\"error\":\"Item not Found\"}")
    end
  end

  describe 'edge case' do
    it 'returns 404 for string ID instead of integer ID when trying to access its merchant' do
      get "/api/v1/items/one/merchant"

      expect(response.status).to eq(404)
      expect(response.body).to eq("{\"error\":\"Item not Found\"}")
    end
  end
end