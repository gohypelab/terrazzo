FactoryBot.define do
  factory :line_item do
    order
    product
    unit_price { 19.99 }
    quantity { 1 }
  end
end
