# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    first_name { "Will" }
    last_name { "Ramos" }
  end

  factory :claimed_user, class: "User" do
    first_name { "Rick" }
    last_name { "Grimes" }
    sequence(:username) { |n| "claimed_#{n}" }
    password { "claimed123" }
    claimed { true }
  end
end
