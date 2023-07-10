FactoryBot.define do
  factory :transaction do
    invoice_id { Faker::Transaction.invoice_id }
    credit_card_number { Faker::Transaction.credit_card_number }
    credit_card_expiration_date { Faker::Transaction.credit_card_expiration_date }
    result { Faker::Transaction.result }
  end
end