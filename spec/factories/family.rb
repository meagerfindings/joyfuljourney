FactoryBot.define do
  factory :family do
    name { Faker::Name.last_name + " Family" }
  end
end