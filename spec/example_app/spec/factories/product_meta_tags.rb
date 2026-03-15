FactoryBot.define do
  factory :product_meta_tag do
    product
    meta_title { "Buy This Product" }
    meta_description { "Best product available" }
  end
end
