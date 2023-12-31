# frozen_string_literal: true

class Customer < ApplicationRecord
  has_many :invoices
  has_many :invoice_items, through: :invoices
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  validates_presence_of :first_name,
                        :last_name
end
