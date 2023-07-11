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
  end
end