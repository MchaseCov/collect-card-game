FactoryBot.define do
  factory :account_deck do
    name { 'account_deck' }
    association :user
    association :archetype
    association :race
    card_count { 0 }
  end
end
