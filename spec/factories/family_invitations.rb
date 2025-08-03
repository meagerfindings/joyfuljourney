FactoryBot.define do
  factory :family_invitation do
    email { "MyString" }
    token { "MyString" }
    family { nil }
    inviter { nil }
    expires_at { "2025-06-19 08:57:42" }
    status { 1 }
  end
end
