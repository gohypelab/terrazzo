FactoryBot.define do
  factory :order do
    customer
    address_line_one { "123 Main St" }
    address_line_two { "Suite 1" }
    address_city { "Springfield" }
    address_state { "IL" }
    address_zip { "62704" }
  end
end
