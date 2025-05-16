class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates :abandoned, inclusion: { in: [true, false] }

  def touch_last_interaction!
    update!(last_interaction_at: Time.current)
  end

  def total_price
    cart_items.sum('quantity * unit_price')
  end
end