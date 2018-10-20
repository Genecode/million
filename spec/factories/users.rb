FactoryBot.define do
  factory :user do
    name { "User #{rand(999)}" }
    sequence(:email) { |n| "exampe_#{n}@mail.ru" }
    is_admin { false }
    balance { 0 }
    after (:build) { |u| u.password_confirmation = u.password = "123123" }
  end
end
