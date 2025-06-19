FactoryBot.define do
  factory :notification do
    user { nil }
    recipient { nil }
    notifiable { nil }
    notification_type { "MyString" }
    title { "MyString" }
    message { "MyText" }
    read_at { "2025-06-19 15:39:17" }
    email_sent_at { "2025-06-19 15:39:17" }
    data { "MyText" }
  end
end
