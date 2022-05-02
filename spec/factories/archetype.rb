FactoryBot.define do
  factory :archetype do
    sequence(:name) { |i| "archetype_#{i}" }
    description { 'archetype description!' }
    resource_type { 'mana' }
    color { 0 }

    factory :token_archetype do
      name { 'Token' }
    end
    factory :wizard_archetype do
      name { 'Wizard' }
    end
    factory :ranger_archetype do
      name { 'Ranger' }
      resource_type { 'hybrid' }
    end
    factory :neutral_archetype do
      name { 'Neutral' }
      resource_type { 'hybrid' }
    end
  end
end
