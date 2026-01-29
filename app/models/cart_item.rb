class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates_numericality_of :total_price, greater_than_or_equal_to: 0
end