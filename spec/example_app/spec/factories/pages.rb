FactoryBot.define do
  factory :page do
    sequence(:title) { |n| "Page #{n}" }
    body { "Page body content" }
    product
  end
end
