# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :items

  validates_presence_of :name

  def self.search_by_name(name_fragment)
    where("name ILIKE '%#{name_fragment}%'").order(:name)
  end
end
