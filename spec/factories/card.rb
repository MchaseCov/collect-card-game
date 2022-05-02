FactoryBot.define do
  factory :card do
    initialize_with { type.present? ? type.constantize.new : Card.new }

    cost { 1 }
    attack { 5 }
    health { 5 }
    health_cap { 5 }
    location { 0 }
    status { 0 }
    position { nil }
    silenced { false }
    association :card_constant
    association :gamestate_deck

    factory :party_card do
      type { 'PartyCard' }
    end
    factory :spell_card do
      type { 'SpellCard' }
    end
  end
end
