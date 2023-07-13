# frozen_string_literal: true

FactoryBot.define do
  factory :invoice_item do
    item
    invoice
    quantity { Faker::Number.within(range: 1..10) }
    unit_price { Faker::Number.within(range: 1..50) }
  end
end
