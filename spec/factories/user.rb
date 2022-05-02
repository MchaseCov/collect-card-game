FactoryBot.define do
  factory :user do
    sequence(:email) { |i| "user#{i}@email.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
  end
end
