FactoryBot.define do
  factory :country do
    code { "US" }
    name { "United States" }

    trait :uk do
      code { "GB" }
      name { "United Kingdom" }
    end
  end
end
