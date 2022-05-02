FactoryBot.define do
  factory :card_reference do
    cost { 1 }
    attack { 5 }
    health { 5 }
    card_type { 'PartyCard' }
    association :card_constant
  end
end
