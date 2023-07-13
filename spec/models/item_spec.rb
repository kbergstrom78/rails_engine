# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:customers).through(:invoices) }
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
      @customer = create(:customer)

      @item1 = create(:item, merchant: @merchant)
      @item2 = create(:item, merchant: @merchant)

      @invoice1 = create(:invoice, merchant: @merchant, customer: @customer)
      @invoice2 = create(:invoice, merchant: @merchant, customer: @customer)

      create(:invoice_item, item: @item1, invoice: @invoice1, quantity: 1, unit_price: 9.99)
      create(:invoice_item, item: @item1, invoice: @invoice2, quantity: 1, unit_price: 9.99)
      create(:invoice_item, item: @item2, invoice: @invoice2, quantity: 1, unit_price: 9.99)
    end

    describe "#invoice_destroy" do
      it 'destroys invoices if the item is the only one on it' do
        expect { @item1.invoice_destroy }.to change { Invoice.count }.by(-1)
        expect(Invoice.find_by(id: @invoice1.id)).to be_nil
        expect(Invoice.find_by(id: @invoice2.id)).to_not be_nil
      end
    end

    context 'when item and merchant exist' do
      it 'updates and returns the item' do
        params = {
          name: 'duct tape',
          description: 'sticky',
          unit_price: 5.99,
          merchant_id: @merchant2.id
        }

        updated_item, error = Item.update_with_merchant_check(@item1.id, @merchant2.id, params)

        expect(updated_item.name).to eq(params[:name])
        expect(updated_item.description).to eq(params[:description])
        expect(updated_item.unit_price).to eq(params[:unit_price])
        expect(updated_item.merchant_id).to eq(@merchant2.id)
        expect(error).to be_nil
      end
    end

    context 'when item does not exist' do
      it 'returns nil and an error message' do
        non_existent_id = @item1.id + 1000
        updated_item, error = Item.update_with_merchant_check(non_existent_id, @merchant2.id, {})

        expect(updated_item).to be_nil
        expect(error).to eq('Item not found')
      end
    end

    context 'when merchant does not exist by id is provided' do
      it 'returns an error message' do
        non_existent_merchant_id = @merchant.id + 1000
        params = { merchant_id: non_existent_merchant_id }

        updated_item, error = Item.update_with_merchant_check(@item1.id, non_existent_merchant_id, params)

        expect(updated_item).to be_nil
        expect(error).to eq('Merchant not found')
      end
    end
  end
end
