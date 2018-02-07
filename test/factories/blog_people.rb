# frozen_string_literal: true
FactoryGirl.define do
  factory :blog_person, class: Blog::Person do
    sequence(:name) { |n| "blog-person-#{n}" }
  end
end
