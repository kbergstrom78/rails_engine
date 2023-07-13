# frozen_string_literal: true

require 'rails_helper'
require 'factory_bot_rails'

RSpec.describe 'Items API', type: :request do
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

    it 'creates a new item' do
      item_params = {
        name: 'pencil thin mustache',
        description: 'face accessory',
        unit_price: 1.99,
        merchant_id: create(:merchant).id
      }

      headers = { 'CONTENT_TYPE' => 'application/json' }

      post api_v1_items_path, headers:, params: JSON.generate(item_params)
      new_item = Item.last

      expect(response).to be_successful
      expect(new_item.name).to eq(item_params[:name])
      expect(new_item.description).to eq(item_params[:description])
      expect(new_item.unit_price).to eq(item_params[:unit_price])
      expect(new_item.merchant_id).to eq(item_params[:merchant_id])
    end

    it 'updates an existing item' do
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      item = create(:item, merchant_id: @merchant.id)

      edit_item_params = {
        name: 'duct tape',
        description: 'everything fixer',
        unit_price: 5.99,
        merchant_id: @merchant2.id
      }

      headers = { 'CONTENT_TYPE' => 'application/json' }

      patch api_v1_item_path(item.id), headers:, params: JSON.generate({ item: edit_item_params })
      edited_item = Item.find_by(id: item.id)

      expect(response).to be_successful
      expect(edited_item.name).to eq(edit_item_params[:name])
      expect(edited_item.name).to_not eq(item.name)
      expect(edited_item.description).to eq(edit_item_params[:description])
      expect(edited_item.description).to_not eq(item.description)
      expect(edited_item.unit_price).to eq(edit_item_params[:unit_price])
      expect(edited_item.unit_price).to_not eq(item.unit_price)
      expect(edited_item.merchant_id).to eq(@merchant2.id)
      expect(edited_item.merchant_id).to_not eq(@merchant.id)
    end

    it 'updates an item with only partial data' do
      @merchant = create(:merchant)
      item = create(:item, merchant_id: @merchant.id)

      partial_item_params = {
        name: 'new name'
      }

      headers = { 'CONTENT_TYPE' => 'application/json' }

      patch api_v1_item_path(item.id), headers:, params: JSON.generate({ item: partial_item_params })
      edited_item = Item.find_by(id: item.id)

      expect(response).to be_successful
      expect(edited_item.name).to eq(partial_item_params[:name])
      expect(edited_item.name).to_not eq(item.name)
    end

    it 'removes an item' do
      @merchant = create(:merchant)
      item = create(:item, merchant_id: @merchant.id)

      expect(Item.count).to eq(1)

      delete api_v1_item_path(item.id)

      expect(response).to be_successful
      expect(response.status).to eq(204)
      expect(Item.count).to eq(0)
      expect { Item.find(item.id) }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  it 'removes an invoice if there are no items on it' do
    @merchant = create(:merchant)
    item = create(:item, merchant_id: @merchant.id)
    customer = create(:customer)
    invoice = create(:invoice, customer_id: customer.id, merchant_id: @merchant.id)
    invoice_item = create(:invoice_item, item_id: item.id, invoice_id: invoice.id)

    delete api_v1_item_path(item.id)

    expect(response).to be_successful
    expect(response.status).to eq(204)
    expect { Invoice.find(invoice.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe 'sad path cases' do
    it 'returns 404 for non-existing item ID' do
      get "/api/v1/items/-1"

      expect(response.status).to eq(404)
      expect(response.body).to eq("{\"error\":\"Item not Found\"}")
    end
  end

  describe 'edge cases' do
    it 'returns 400 or 404 for a bad merchant ID' do
      bad_merchant_id = -1

      get api_v1_merchant_items_path(bad_merchant_id)

      expect(response.status).to eq(404)
      expect(response.body).to eq("{\"error\":\"Couldn't find merchant with 'id'=-1\"}")

    end
  end
end
