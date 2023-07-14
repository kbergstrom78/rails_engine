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

    it 'can find all items that are over a min price' do
      get api_v1_items_find_all_path(min_price: 12.00)
      items_data = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful
      expect(items_data[:data].count).to eq(5)
    end
  end

  describe 'sad path' do
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
    
    it 'returns a 404 status code if bad data' do
      get api_v1_items_find_all_path(name: '')

      expect(response.status).to eq(404)
    end

    it 'returns a 404 status code if name parameter is an empty string' do
      get api_v1_items_find_all_path(name: '')
      expect(response.status).to eq(404)
    end

    it 'returns a 400 status code if name and price parameters are sent together' do
      get api_v1_items_find_all_path(name: 'fish', min_price: 5)
      expect(response.status).to eq(400)
    end

    it 'returns a 400 status code if min_price or max_price is less than 0' do
      get api_v1_items_find_all_path(min_price: -5)
      expect(response.status).to eq(400)
    end

    it 'returns a 200 status and empty data array when no results found' do
      get api_v1_items_find_all_path(name: 'Nonexistent')
      expect(response.status).to eq(200)
      parsed_body = JSON.parse(response.body)
      expect(parsed_body["data"]).to be_empty
    end
  end
end
