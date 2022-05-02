FactoryBot.define do
  factory :player do
    health_cap { 30 }
    health_current { 30 }
    cost_cap { 0 }
    cost_current { 0 }
    resource_cap { 0 }
    resource_current { 0 }
    status { 0 }
    attack { 0 }
    association :race
    association :archetype
    association :user
    association :game

    factory :player_one do
      turn_order { true }
    end
    factory :player_two do
      turn_order { false }
    end
  end
end
