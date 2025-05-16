FactoryBot.define do
  factory :product do
    name { Faker::Commerce.product_name }
    unit_price { Faker::Commerce.price(range: 1..100.0) }
  end
end
