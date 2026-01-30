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
end