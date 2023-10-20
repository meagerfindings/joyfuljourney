# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    first_name { "Will" }
    last_name { "Ramos" }
    username { "sunEater" }
    birthdate { "January 1, 1993"}
    claimed { false }
  end
end
