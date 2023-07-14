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
      Item.destroy_all
      @merchant = create(:merchant)
      @merchant2 = create(:merchant)
      @customer = create(:customer)

      @item1 = create(:item, name: 'slinky', unit_price: 4.99, merchant: @merchant)
      @item2 = create(:item, name: 'slinky for girls', unit_price: 5.99, merchant: @merchant)
      @item3 = create(:item, name: 'super slinky', unit_price: 25.00, merchant: @merchant)
      @item4 = create(:item, name: 'robo slinky', unit_price: 500.00, merchant: @merchant)

      @invoice1 = create(:invoice, merchant: @merchant, customer: @customer)
      @invoice2 = create(:invoice, merchant: @merchant, customer: @customer)

      create(:invoice_item, item: @item1, invoice: @invoice1, quantity: 1, unit_price: 9.99)
      create(:invoice_item, item: @item1, invoice: @invoice2, quantity: 1, unit_price: 9.99)
      create(:invoice_item, item: @item2, invoice: @invoice2, quantity: 1, unit_price: 9.99)
    end

    describe '#invoice_destroy' do
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

    describe '#find_all' do
      context 'when searching by name' do
        it 'returns items that match the name' do
          expect(Item.find_all(name: 'slinky').count).to eq(4)
          expect(Item.find_all(name: 'slinky', min_price: 2.99)).to eq(false)
          expect(Item.find_all(name: 'slinky', min_price: 2.99, max_price: 501.99)).to eq(false)
          expect(Item.find_all(min_price: 4.99).count).to eq(5)
          expect(Item.find_all(max_price: 500.00).count).to eq(5)
          expect(Item.find_all(name: '')).to eq(false)
          expect(Item.find_all(min_price: -1)).to eq(false)
          expect(Item.find_all(max_price: -1)).to eq(false)
        end

        it 'returns an empty array if no items match the name' do
          items = Item.find_all(name: 'banana', min_price: nil, max_price: nil)

          expect(items).to be_empty
        end
      end

      context 'when searching by min_price and max_price' do
        it 'returns items within the price range' do
          items = Item.find_all(name: nil, min_price: 10.0, max_price: 20.0)

          expect(items).to contain_exactly(@item2)
        end

        it 'returns an empty array if no items match the price range' do
          items = Item.find_all(name: nil, min_price: 30.0, max_price: 40.0)

          expect(items).to be_empty
        end
      end

      context 'when searching by name and price range' do
        it 'returns items that match the name and price range' do
          items = Item.find_all(name: 'fish', min_price: 10.0, max_price: 20.0)

          expect(items).to contain_exactly(@item2)
        end

        it 'returns an empty array if no items match the name and price range' do
          items = Item.find_all(name: 'banana', min_price: 10.0, max_price: 20.0)

          expect(items).to be_empty
        end
      end

      context 'when not providing any parameters' do
        it 'returns all items' do
          items = Item.find_all(name: nil, min_price: nil, max_price: nil)

          expect(items).to contain_exactly(@item1, @item2)
        end
      end
    end

    describe '.find_by_name_fragment' do
      it 'returns items that match the name fragment' do
        items = Item.find_by_name_fragment('fish')

        expect(items).to contain_exactly(@item1, @item2)
      end

      it 'returns an empty array if no items match the name fragment' do
        items = Item.find_by_name_fragment('banana')

        expect(items).to be_empty
      end
    end

    describe '.find_by_price' do
      it 'returns items within the price range' do
        items = Item.find_by_price(min_price: 10.0, max_price: 20.0)

        expect(items).to contain_exactly(@item2)
      end

      it 'returns items with a price greater than or equal to the min_price' do
        items = Item.find_by_price(min_price: 10.0, max_price: nil)

        expect(items).to contain_exactly(@item2)
      end

      it 'returns items with a price less than or equal to the max_price' do
        items = Item.find_by_price(min_price: nil, max_price: 20.0)

        expect(items).to contain_exactly(@item1, @item2)
      end

      it 'returns all items if no price parameters are provided' do
        items = Item.find_by_price(min_price: nil, max_price: nil)

        expect(items).to contain_exactly(@item1, @item2)
      end
    end
  end
end
