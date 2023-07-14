# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'class methods' do
    before :each do
      @merchant1 = create(:merchant, name: "John's Goods")
      @merchant2 = create(:merchant, name: "Jane's Goods")
      @merchant3 = create(:merchant, name: "Apple Store")
    end

    describe '.search_by_name' do
      it 'returns merchants that match the name fragment' do
        result = Merchant.search_by_name('Goods')

        expect(result).to match_array([@merchant1, @merchant2])
      end

      it 'is case insensitive' do
        result = Merchant.search_by_name('goods')

        expect(result).to match_array([@merchant1, @merchant2])
      end

      it 'returns an empty array if no merchants match the name fragment' do
        result = Merchant.search_by_name('Nonexistent')

        expect(result).to be_empty
      end
    end
  end
end
