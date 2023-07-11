# frozen_string_literal: true

class Merchant < ApplicationRecord
  has_many :items

  validates_presence_of :name
end
