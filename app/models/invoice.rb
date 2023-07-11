# frozen_string_literal: true

class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items
  has_many :items, through: :invoice_items

  validates_presence_of :customer_id,
                        :merchant_id,
                        :status
end
