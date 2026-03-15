FactoryBot.define do
  factory :blog_post, class: "Blog::Post" do
    sequence(:title) { |n| "Blog Post #{n}" }
    body { "Post body content" }
    published_at { Time.current }
  end

  factory :blog_tag, class: "Blog::Tag" do
    sequence(:name) { |n| "tag-#{n}" }
  end
end
