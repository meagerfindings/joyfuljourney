FactoryBot.define do
  factory :reaction do
    reaction_type { Reaction::REACTION_TYPES.sample }
    association :user
    association :post
  end
end