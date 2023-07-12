require 'rails_helper'

RSpec.describe 'Item Merchant API' do
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
end