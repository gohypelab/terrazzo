module ModelHelpers
  def create_country(code: "US", name: "United States")
    Country.find_or_create_by!(code: code) { |c| c.name = name }
  end

  def create_customer(name: "Alice", email: "alice@example.com", country: nil)
    country ||= create_country
    Customer.create!(name: name, email: email, country_code: country.code, kind: "standard")
  end

  def create_order(customer: nil, **attrs)
    customer ||= create_customer
    defaults = {
      customer: customer,
      address_line_one: "123 Main St",
      address_line_two: "Apt 1",
      address_city: "New York",
      address_state: "NY",
      address_zip: "10001"
    }
    Order.create!(defaults.merge(attrs))
  end
end

RSpec.configure do |config|
  config.include ModelHelpers
end
