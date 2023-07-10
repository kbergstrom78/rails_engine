class Item < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :name,
                        :unit_price,
                        :description,
                        :merchant_id
end