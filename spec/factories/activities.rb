FactoryBot.define do
  factory :activity do
    user { nil }
    trackable { nil }
    activity_type { "MyString" }
    data { "MyText" }
    occurred_at { "2025-06-19 15:43:04" }
  end
end
