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
      dashboard =
        association_search_dashboard(
          territory: Terrazzo::Field::BelongsTo.with_options(searchable: true, searchable_fields: ["code"])
        )
      country = create_country(code: "NLD", name: "Netherlands")
      customer = create_customer(name: "Country Code Customer", email: "country-code@example.com", country: country)
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "NLD").run

      expect(results).to contain_exactly(customer)
    end

    it "treats SQL wildcard characters as literal text in association search" do
      dashboard =
        association_search_dashboard(
          territory: Terrazzo::Field::BelongsTo.with_options(searchable: true, searchable_fields: ["code"])
        )
      country = create_country(code: "A_B", name: "Underscore Country")
      customer =
        create_customer(name: "Association Wildcard Customer", email: "assoc-wildcard@example.com", country: country)
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "A_B").run

      expect(results).to contain_exactly(customer)
    end

    it "uses conventional display columns for searchable associations by default" do
      dashboard = association_search_dashboard(territory: Terrazzo::Field::BelongsTo.with_options(searchable: true))
      country = create_country(code: "DE", name: "Germany")
      customer = create_customer(name: "Fallback Customer", email: "fallback@example.com", country: country)
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "Germany").run

      expect(results).to contain_exactly(customer)
    end

    it "deduplicates parent records when has_many association search matches multiple children" do
      dashboard =
        association_search_dashboard(
          orders: Terrazzo::Field::HasMany.with_options(searchable: true, searchable_fields: ["address_city"])
        )
      customer = create_customer(name: "Has Many Search", email: "has-many-search@example.com")
      2.times { create_order(customer: customer, address_city: "Needle City") }
      scoped = Customer.where(id: @customers.map(&:id) + [customer.id])

      results = described_class.new(scoped, dashboard, "Needle").run

      expect(results.to_a).to contain_exactly(customer)
      expect(results.count).to eq(1)
      expect(results.distinct_value).to be_falsey
    end

    it "ignores association searchable_fields that are not real columns" do
      dashboard =
        association_search_dashboard(
          territory: Terrazzo::Field::BelongsTo.with_options(searchable: true, searchable_fields: ["missing_column"])
        )

      results = described_class.new(scope, dashboard, "anything").run

      expect(results).to contain_exactly(*@customers)
    end

    it "keeps an explicit removal of the parent default scope" do
      stub_const("ScopedSearchCustomer", Class.new(Customer) do
        default_scope { where(name: "Not visible") }
      end)
      dashboard = association_search_dashboard(territory: Terrazzo::Field::BelongsTo.with_options(searchable: true))
      scoped = ScopedSearchCustomer.unscoped.where(id: @customers.first.id)

      results = described_class.new(scoped, dashboard, "United States").run

      expect(results.map(&:id)).to eq([@customers.first.id])
    end

    it "keeps the outer default scope and selects only IDs in the subquery" do
      stub_const("SelectedSearchCustomer", Class.new(Customer) do
        default_scope { where(name: "Alice Smith").select(:id, :name) }
      end)
      dashboard = association_search_dashboard(territory: Terrazzo::Field::BelongsTo.with_options(searchable: true))
      scoped = SelectedSearchCustomer.where(id: @customers.map(&:id))

      results = described_class.new(scoped, dashboard, "United States").run

      expect(results.map(&:id)).to eq([@customers.first.id])
    end

    it "searches text beyond the first 256 characters" do
      customer = create_customer(name: "x" * 300 + "Needle")

      expect(described_class.new(Customer.all, dashboard, "Needle").run).to contain_exactly(customer)
    end
  end

  describe "JSON and numeric fields" do
    before do
      ActiveRecord::Base
        .connection
        .create_table(:search_documents, temporary: true) do |table|
          table.json :metadata
          table.integer :customer_id
        end
      stub_const(
        "SearchDocument",
        Class.new(ActiveRecord::Base) do
          store_accessor :metadata, :filename
          belongs_to :customer
        end
      )
      stub_const(
        "SearchCustomer",
        Class.new(ActiveRecord::Base) do
          self.table_name = "customers"
          has_many :search_documents, foreign_key: :customer_id
        end
      )
    end

    after { ActiveRecord::Base.connection.drop_table(:search_documents) }

    def document_dashboard(types)
      Class.new(Terrazzo::BaseDashboard) { const_set(:ATTRIBUTE_TYPES, types.freeze) }.new
    end

    it "searches JSON store accessors with literal wildcard characters" do
      match = SearchDocument.create!(customer: @customers.first, filename: "Report_100%.pdf")
      SearchDocument.create!(customer: @customers.first, filename: "ReportX1000.pdf")
      fields = document_dashboard(filename: Terrazzo::Field::String.with_options(searchable: true))

      expect(described_class.new(SearchDocument.all, fields, "report_100%").run).to contain_exactly(match)
    end

    it "searches a numeric column as text" do
      document = SearchDocument.create!(customer: @customers.first)
      fields = document_dashboard(id: Terrazzo::Field::String.with_options(searchable: true))

      expect(described_class.new(SearchDocument.all, fields, document.id.to_s).run).to contain_exactly(document)
      expect(described_class.new(SearchDocument.all, fields, "missing").run).to be_empty
    end

    it "searches an association when the parent has a JSON column" do
      document = SearchDocument.create!(customer: @customers.first, filename: "report.pdf")
      fields = document_dashboard(customer: Terrazzo::Field::BelongsTo.with_options(searchable: true))

      expect(described_class.new(SearchDocument.all, fields, "Alice").run).to contain_exactly(document)
    end

    it "searches store accessors on associations without duplicate parents" do
      2.times { SearchDocument.create!(customer: @customers.first, filename: "report.pdf") }
      SearchDocument.create!(customer: @customers.last, filename: "report.pdf")
      fields =
        document_dashboard(
          search_documents: Terrazzo::Field::HasMany.with_options(searchable: true, searchable_fields: [:filename])
        )
      scoped = SearchCustomer.where(id: @customers.first.id)

      expect(described_class.new(scoped, fields, "report").run.map(&:id)).to eq([@customers.first.id])
    end

    %w[Mysql2 Trilogy].each do |adapter|
      it "uses MySQL cast types and JSON paths with #{adapter}" do
        allow(SearchDocument.connection).to receive(:adapter_name).and_return(adapter)
        fields = document_dashboard(
          filename: Terrazzo::Field::String.with_options(searchable: true),
          id: Terrazzo::Field::Number.with_options(searchable: true)
        )

        sql = described_class.new(SearchDocument.all, fields, "report").run.to_sql

        expect(sql).to include('CAST(JSON_UNQUOTE(JSON_EXTRACT("search_documents"."metadata", \'$."filename"\')) AS CHAR)')
        expect(sql).to include('CAST("search_documents"."id" AS CHAR)')
      end
    end
  end

  def association_search_dashboard(attribute_overrides)
    base_types = CustomerDashboard::ATTRIBUTE_TYPES.merge(name: Terrazzo::Field::String, email: Terrazzo::Field::Email)

    Class.new(CustomerDashboard) { const_set(:ATTRIBUTE_TYPES, base_types.merge(attribute_overrides).freeze) }.new
  end
end
