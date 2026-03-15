FactoryBot.define do
  factory :series do
    sequence(:name) { |n| "Series #{n}" }
  end
end
