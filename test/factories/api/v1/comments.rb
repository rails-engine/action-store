FactoryGirl.define do
  factory :comment do
    sequence(:body) { |n| "comment body #{n}" }
    association :user, factory: :user
    association :post, factory: :post
  end
end
