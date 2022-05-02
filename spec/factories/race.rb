FactoryBot.define do
  factory :race do
    sequence(:name) { |i| "race_#{i}" }
    description { 'racial description!' }
    health_modifier { 5 }
    cost_modifier { 5 }
    resource_modifier { 5 }
  end
end
