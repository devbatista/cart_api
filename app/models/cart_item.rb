class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  before_validation :set_prices

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  private

  def set_prices
    self.unit_price = product.price
    self.total_price = unit_price.to_d * quantity.to_i
  end
end