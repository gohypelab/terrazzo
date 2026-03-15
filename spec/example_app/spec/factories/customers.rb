FactoryBot.define do
  factory :customer do
    sequence(:name) { |n| "Customer #{n}" }
    sequence(:email) { |n| "customer#{n}@example.com" }
    kind { "standard" }
    territory { Country.find_by(code: "US") || association(:country) }
  end
end
