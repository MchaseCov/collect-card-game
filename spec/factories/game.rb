FactoryBot.define do
  factory :game do
    turn { true }
    ongoing { true }
    status { 0 }
  end
end
