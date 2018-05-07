# frozen_string_literal: true
FactoryBot.define do
  factory :post do
    sequence(:title) { |n| "post-title-#{n}" }
    association :user, factory: :user
  end
end
