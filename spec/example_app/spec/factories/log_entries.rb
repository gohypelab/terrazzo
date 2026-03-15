FactoryBot.define do
  factory :log_entry do
    action { "create" }
    loggable { association(:customer) }
  end
end
