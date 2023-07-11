# frozen_string_literal: true

FactoryBot.define do
  factory :invoice do
    customer_id { Faker::Invoice.customer_id }
    merchant_id { Faker::Invoice.merchant_id }
    status { Faker::Invoice.status }
  end
end
