FactoryBot.define do
  factory :buff do
    name { "Buff Name"}
    target_method { 'increase_health_cap' }
    removal_method { 'decrease_health_cap' }
    modifier {2}

  end
end
