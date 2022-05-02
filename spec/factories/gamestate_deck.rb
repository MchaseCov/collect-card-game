FactoryBot.define do
  factory :gamestate_deck do
    card_count { 30 }
    association :player
    association :game
  end
end
