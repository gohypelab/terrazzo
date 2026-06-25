require "spec_helper"

RSpec.describe Terrazzo::Search do
  let(:dashboard) { CustomerDashboard.new }

  before do
    @customers = [
      create_customer(name: "Alice Smith", email: "alice@example.com"),
      create_customer(name: "Bob Jones", email: "bob@example.com"),
      create_customer(name: "Charlie Smith", email: "charlie@example.com")
    ]
  end

  let(:scope) { Customer.where(id: @customers.map(&:id)) }

  describe "#run" do
    it "returns all records for blank term" do
      search = described_class.new(scope, dashboard, nil)
      expect(search.run.count).to eq(3)
    end

    it "returns all records for empty string term" do
      search = described_class.new(scope, dashboard, "")
      expect(search.run.count).to eq(3)
    end

    it "filters by LIKE on searchable string fields" do
      search = described_class.new(scope, dashboard, "Smith")
      results = search.run
      expect(results.count).to eq(2)
      expect(results.map(&:name)).to contain_exactly("Alice Smith", "Charlie Smith")
    end

    it "search is case-insensitive" do
      search = described_class.new(scope, dashboard, "alice")
      results = search.run
      expect(results.count).to eq(1)
      expect(results.first.name).to eq("Alice Smith")
    end

    it "searches across multiple searchable fields" do
      search = described_class.new(scope, dashboard, "bob@example")
      results = search.run
      expect(results.count).to eq(1)
      expect(results.first.name).to eq("Bob Jones")
    end

    it "treats SQL wildcard characters as literal search text" do
      percent_customer = create_customer(name: "Literal 100%", email: "literal-percent@example.com")
      underscore_customer = create_customer(name: "Literal_under", email: "literal-underscore@example.com")
      scoped = Customer.where(id: @customers.map(&:id) + [percent_customer.id, underscore_customer.id])

      expect(described_class.new(scoped, dashboard, "100%").run).to contain_exactly(percent_customer)
      expect(described_class.new(scoped, dashboard, "_under").run).to contain_exactly(underscore_customer)
    end

    it "searches explicit searchable_fields on associations" do
      dashboard = association_search_dashboard(
        territory: Terrazzo::Field::BelongsTo.with_options(
          searchable: true,
          searchable_fields: ["code"]
        )
      )
      country = create_country(code: "NLD", name: "Netherlands")
      customer = create_customer(name: "Country Code Customer", email: "country-code@example.com", country: country)
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "NLD").run

      expect(results).to contain_exactly(customer)
    end

    it "treats SQL wildcard characters as literal text in association search" do
      dashboard = association_search_dashboard(
        territory: Terrazzo::Field::BelongsTo.with_options(
          searchable: true,
          searchable_fields: ["code"]
        )
      )
      country = create_country(code: "A_B", name: "Underscore Country")
      customer = create_customer(name: "Association Wildcard Customer", email: "assoc-wildcard@example.com", country: country)
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "A_B").run

      expect(results).to contain_exactly(customer)
    end

    it "uses conventional display columns for searchable associations by default" do
      dashboard = association_search_dashboard(
        territory: Terrazzo::Field::BelongsTo.with_options(searchable: true)
      )
      country = create_country(code: "DE", name: "Germany")
      customer = create_customer(name: "Fallback Customer", email: "fallback@example.com", country: country)
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "Germany").run

      expect(results).to contain_exactly(customer)
    end

    it "deduplicates parent records when has_many association search matches multiple children" do
      dashboard = association_search_dashboard(
        orders: Terrazzo::Field::HasMany.with_options(
          searchable: true,
          searchable_fields: ["address_city"]
        )
      )
      customer = create_customer(name: "Has Many Search", email: "has-many-search@example.com")
      2.times { create_order(customer: customer, address_city: "Needle City") }
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "Needle").run

      expect(results.to_a).to contain_exactly(customer)
      expect(results.count).to eq(1)
    end

    it "ignores association searchable_fields that are not real columns" do
      dashboard = association_search_dashboard(
        territory: Terrazzo::Field::BelongsTo.with_options(
          searchable: true,
          searchable_fields: ["missing_column"]
        )
      )

      results = described_class.new(scope, dashboard, "anything").run

      expect(results).to contain_exactly(*@customers)
    end
  end

  def association_search_dashboard(attribute_overrides)
    base_types = CustomerDashboard::ATTRIBUTE_TYPES.merge(
      name: Terrazzo::Field::String,
      email: Terrazzo::Field::Email
    )

    Class.new(CustomerDashboard) do
      const_set(:ATTRIBUTE_TYPES, base_types.merge(attribute_overrides).freeze)
    end.new
  end
end
