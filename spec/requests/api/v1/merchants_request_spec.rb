require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe 'Merchants API' do
  describe 'happy path' do
    it 'sends a list of merchants' do
      FactoryBot.create_list(:merchant, 9)

      get '/api/v1/merchants'

      expect(response).to be_successful

      merchants_info = JSON.parse(response.body, symbolize_names: true)
      expect(merchants_info[:data].count).to eq(9)

      merchants_info[:data].each do |merchant|
        expect(merchant[:attributes]).to have_key(:name)
        expect(merchant[:attributes][:name]).to be_a(String)
      end
    end

    it 'can get one merchant by its id' do
      id = create(:merchant).id

      get "/api/v1/merchants/#{id}"

      merchant_info = JSON.parse(response.body, symbolize_names: true)

      expect(response).to be_successful

      expect(merchant_info[:data][:attributes]).to have_key(:name)
      expect(merchant_info[:data][:attributes][:name]).to be_a(String)
      expect(merchant_info[:data][:id]).to eq(id.to_s)
    end
  end
end