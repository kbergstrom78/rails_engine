# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :merchant
  has_many :invoice_items, dependent: :delete_all
  has_many :invoices, through: :invoice_items
  has_many :customers, through: :invoices

  validates_presence_of :name,
                        :unit_price,
                        :description,
                        :merchant_id

  def self.update_with_merchant_check(id, merchant_id, item_params)
    item = find_by(id:)
    return [nil, 'Item not found'] unless item

    merchant = Merchant.find_by(id: merchant_id) if merchant_id
    return [nil, 'Merchant not found'] if merchant_id && !merchant

    item.update!(item_params)
    [item, nil]
  end

  def invoice_destroy
    invoices_to_destroy = self.invoices.select { |invoice| invoice.invoice_items.count == 1 }
    invoices_to_destroy.each(&:destroy)
  end
end
