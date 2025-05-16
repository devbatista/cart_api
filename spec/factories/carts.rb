FactoryBot.define do
  factory :cart do
    abandoned { false }
    last_interaction_at { Time.current }
  end
end