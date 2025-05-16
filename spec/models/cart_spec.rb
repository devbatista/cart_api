require 'rails_helper'

RSpec.describe Cart, type: :model do
  subject { build(:cart) }

  it { should validate_inclusion_of(:abandoned).in_array([true, false]) }

  it { should have_many(:cart_items).dependent(:destroy) }
  it { should have_many(:products).through(:cart_items) }

  describe '#total_price' do
    it 'soma o total dos itens do carrinho' do
      cart = create(:cart)
      product = create(:product, unit_price: 10.0)
      create(:cart_item, cart: cart, product: product, quantity: 2, unit_price: 10.0)
      create(:cart_item, cart: cart, product: product, quantity: 3, unit_price: 10.0)

      expect(cart.total_price).to eq(50.0)
    end
  end
end
