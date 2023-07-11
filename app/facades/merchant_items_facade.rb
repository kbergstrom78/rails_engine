# frozen_string_literal: true

class MerchantItemsFacade
  def self.find_by_merch_id(merch_id)
    Merchant.find(merch_id).items
  end
end
