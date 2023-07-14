# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Search Merchant API', type: :request do
  describe 'happy path' do
    before :each do
      @merchant1 = create(:merchant, name: 'Patty O Furniture')
      @merchant2 = create(:merchant, name: 'Patio Furniture')
      @merchant3 = create(:merchant, name: 'Paddyo Furniture')

      query_params = { name: 'patio' }
      get '/api/v1/merchants/find', params: query_params
    end

    it 'returns a successful response' do
      expect(response).to be_successful
    end

    it 'returns a single merchant with the matching fragment' do
      merchant_data = JSON.parse(response.body, symbolize_names: true)
      expect(merchant_data).to have_key(:data)
      expect(merchant_data.count).to eq(1)

      merchants = merchant_data[:data]

      expect(merchants).to be_a(Hash)

      expect(merchants).to have_key(:id)
      expect(merchants[:id]).to eq(@merchant2.id.to_s)
      expect(merchants[:id]).to_not eq(@merchant1.id.to_s)

      expect(merchants).to have_key(:attributes)
      expect(merchants[:attributes]).to have_key(:name)
      expect(merchants[:attributes][:name]).to eq(@merchant2.name)
      expect(merchants[:attributes][:name]).to_not eq(@merchant3.name)
    end
  end

  describe 'sad path' do
    it 'returns an empty array if no matches are found' do
      query_params = { name: 'uhoh' }

      get '/api/v1/merchants/find', params: query_params

      expect(response).to be_successful
      expect(response.status).to eq(200)

      merchant_data = JSON.parse(response.body, symbolize_names: true)

      expect(merchant_data[:data][:merchants]).to eq([])
    end
  end
end
