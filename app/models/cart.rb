class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  scope :active, -> { where(abandoned: false) }
  scope :abandoned, -> { where(abandoned: true) }

  def update_total_price!
    update!(total_price: cart_items.sum(:total_price))
  end

  def touch_interaction!
    update_columns(
      last_interaction_at: Time.current,
      abandoned: false,
      updated_at: Time.current
    )
  end

  def mark_as_abandoned!
    update_columns(
      abandoned: true,
      abandoned_at: Time.current,
      updated_at: Time.current
    )
  end
end
