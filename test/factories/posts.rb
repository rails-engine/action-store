FactoryGirl.define do
  factory :post do
    sequence(:title) { |n| "post-title-#{n}" }
    association :user, factory: :user
  end
end
