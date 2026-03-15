FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    price { 19.99 }
    description { "A test product" }
    image_url { "https://picsum.photos/200" }
  end
end
