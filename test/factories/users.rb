FactoryGirl.define do
  factory :user do
    sequence(:name) { |n| "user-#{n}" }
  end
end
