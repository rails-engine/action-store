FactoryGirl.define do
  factory :blog_post, class: Blog::Post do
    sequence(:title) { |n| "blog-post-title-#{n}" }
    association :user, factory: :user
  end
end
