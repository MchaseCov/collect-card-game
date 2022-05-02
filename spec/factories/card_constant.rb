FactoryBot.define do
  factory :card_constant do
    sequence(:name) { |i| "card_constant_#{i}" }
    association :archetype, factory: :archetype
  end
end
