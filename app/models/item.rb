# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name,
                        :unit_price,
                        :description,
                        :merchant_id

  def self.update_with_merchant_check(id, merchant_id, item_params)
    item = find_by(id: id)
    return [nil, 'Item not found'] unless item

    merchant = Merchant.find_by(id: merchant_id) if merchant_id
    if merchant_id && !merchant
      return [nil, 'Merchant not found']
    end

    item.update!(item_params)
    [item, nil]
  end
end
