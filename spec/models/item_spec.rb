# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:merchant_id) }
  end

  describe 'class methods' do
    before :each do
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      @item = create(:item, merchant_id: @merchant.id)
    end

    context 'when item and merchant exist' do
      it 'updates and returns the item' do
        params = {
          name: 'duct tape',
          description: 'sticky',
          unit_price: 5.99,
          merchant_id: @merchant2.id
        }

        updated_item, error = Item.update_with_merchant_check(@item.id, @merchant2.id, params)

        expect(updated_item.name).to eq(params[:name])
        expect(updated_item.description).to eq(params[:description])
        expect(updated_item.unit_price).to eq(params[:unit_price])
        expect(updated_item.merchant_id).to eq(@merchant2.id)
        expect(error).to be_nil
      end
    end

    context 'when item does not exist' do
      it 'returns nil and an error message' do
        non_existent_id = @item.id + 1000
        updated_item, error = Item.update_with_merchant_check(non_existent_id, @merchant2.id, {})

        expect(updated_item).to be_nil
        expect(error).to eq('Item not found')
      end
    end

    context 'when merchant does not exist by id is provided' do
      it 'returns an error message' do
        non_existent_merchant_id = @merchant.id + 1000
        params = { merchant_id: non_existent_merchant_id }

        updated_item, error = Item.update_with_merchant_check(@item.id, non_existent_merchant_id, params)

        expect(updated_item).to be_nil
        expect(error).to eq('Merchant not found')
      end
    end
  end
end
