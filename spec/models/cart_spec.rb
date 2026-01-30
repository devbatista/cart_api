require 'rails_helper'

RSpec.describe Cart, type: :model do
  describe 'validations' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)

      expect(cart).not_to be_valid
      expect(cart.errors[:total_price]).to include('must be greater than or equal to 0')
    end
  end

  describe '#mark_as_abandoned!' do
    it 'marks the cart as abandoned and sets abandoned_at' do
      cart = described_class.create!(total_price: 0, abandoned: false)

      cart.mark_as_abandoned!
      cart.reload

      expect(cart.abandoned).to eq(true)
      expect(cart.abandoned_at).to be_present
    end
  end

  describe '#touch_interaction!' do
    it 'updates last_interaction_at and resets abandoned flag' do
      cart = described_class.create!(
        total_price: 0,
        abandoned: true,
        last_interaction_at: 5.hours.ago
      )

      cart.touch_interaction!
      cart.reload

      expect(cart.abandoned).to eq(false)
      expect(cart.last_interaction_at).to be_within(1.second).of(Time.current)
    end
  end

  describe '#update_total_price!' do
    it 'recalculates total_price by summing cart items total_price' do
      cart = described_class.create!(total_price: 0, abandoned: false)
      product1 = Product.create!(name: 'P1', price: 10.0)
      product2 = Product.create!(name: 'P2', price: 5.0)

      cart.cart_items.create!(product: product1, quantity: 2, unit_price: 10.0, total_price: 20.0)
      cart.cart_items.create!(product: product2, quantity: 1, unit_price: 5.0, total_price: 5.0)

      cart.update_total_price!
      cart.reload

      expect(cart.total_price).to eq(25.0)
    end
  end

  describe 'scopes' do
    it '.active returns only non-abandoned carts' do
      active_cart = described_class.create!(total_price: 0, abandoned: false)
      _abandoned_cart = described_class.create!(total_price: 0, abandoned: true)

      expect(described_class.active).to contain_exactly(active_cart)
    end

    it '.abandoned returns only abandoned carts' do
      _active_cart = described_class.create!(total_price: 0, abandoned: false)
      abandoned_cart = described_class.create!(total_price: 0, abandoned: true)

      expect(described_class.abandoned).to contain_exactly(abandoned_cart)
    end
  end
end