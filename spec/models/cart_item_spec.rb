require 'rails_helper'

RSpec.describe CartItem, type: :model do
  subject { build(:cart_item) }

  it { should belong_to(:cart) }
  it { should belong_to(:product) }

  it { should validate_presence_of(:quantity) }
  it { should validate_numericality_of(:quantity).is_greater_than(0) }

  it { should validate_presence_of(:unit_price) }
  it { should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }

  describe '#total_price' do
    it 'retorna o preço total multiplicando unit_price por quantity' do
      cart_item = build(:cart_item, quantity: 3, unit_price: 15.0)
      expect(cart_item.total_price).to eq(45.0)
    end
  end
end
