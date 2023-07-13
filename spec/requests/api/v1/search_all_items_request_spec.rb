require 'rails_helper'

RSpec.describe 'Search All Items API', type: :request do
  describe 'happy path' do
    before :each do
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      @merchant3 = create(:merchant)
      @item = create(:item, merchant_id: @merchant.id, unit_price: 5.00, name: 'one fish')
      @item2 = create(:item, merchant_id: @merchant.id, unit_price: 10.00, name: 'two fish')
      @item3 = create(:item, merchant_id: @merchant2.id, unit_price: 15.00, name: 'red fish')
      @item4 = create(:item, merchant_id: @merchant2.id, unit_price: 20.00, name: 'blue fish')
      @item5 = create(:item, merchant_id: @merchant2.id, unit_price: 25.00, name: 'go fish')
      @item6 = create(:item, merchant_id: @merchant3.id, unit_price: 50.00, name: 'you fish')
      @item7 = create(:item, merchant_id: @merchant3.id, unit_price: 1000.00, name: 'phish fish')
    end

    it 'can find all items that match a search term' do
      get api_v1_items_find_all_path(name: 'fish')

      items_data = JSON.parse(response.body, symbolize_names: true)
      expect(response).to be_successful
      expect(items_data[:data].count).to eq(7)
    end
  end
end