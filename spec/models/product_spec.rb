require 'rails_helper'

RSpec.describe Product, type: :model do
  subject { build(:product) }

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:unit_price) }
  it { should validate_numericality_of(:unit_price).is_greater_than_or_equal_to(0) }

  it { should have_many(:cart_items) }
  it { should have_many(:carts).through(:cart_items) }
end
