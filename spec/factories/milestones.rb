FactoryBot.define do
  factory :milestone do
    title { "My First Steps" }
    description { "Baby took their first steps today!" }
    milestone_date { Date.current }
    milestone_type { "first_steps" }
    is_private { false }
    
    association :milestoneable, factory: :user
    association :created_by_user, factory: :user

    trait :birthday do
      title { "5th Birthday" }
      milestone_type { "birthday" }
      description { "Happy 5th birthday!" }
    end

    trait :graduation do
      title { "High School Graduation" }
      milestone_type { "graduation" }
      description { "Graduated from high school with honors" }
    end

    trait :private_milestone do
      is_private { true }
    end

    trait :for_family do
      association :milestoneable, factory: :family
    end

    trait :for_post do
      association :milestoneable, factory: :post
    end
  end
end