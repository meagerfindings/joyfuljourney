# spec/factories/posts.rb

FactoryBot.define do
  factory :post do
    title { 'Sample Post Title' }
    body { 'This is a sample post body with more than ten characters.' }
    association :user
  end
end
