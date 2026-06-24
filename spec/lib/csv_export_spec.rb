require "csv"
require "spec_helper"

RSpec.describe Terrazzo::CsvExport do
  class CsvCustomerDashboard < Terrazzo::BaseDashboard
    def self.model
      Customer
    end

    ATTRIBUTE_TYPES = {
      id: Terrazzo::Field::String,
      name: Terrazzo::Field::String,
      email: Terrazzo::Field::Email,
      territory: Terrazzo::Field::BelongsTo,
    }.freeze

    COLLECTION_ATTRIBUTES = %i[id name email territory].freeze
    SHOW_PAGE_ATTRIBUTES = COLLECTION_ATTRIBUTES
    FORM_ATTRIBUTES = %i[name email territory].freeze
  end

  it "exports collection attributes with field-serialized values" do
    country = create_country(code: "CA", name: "Canada")
    alice = create_customer(name: "Alice, Inc.", email: "alice@example.com", country: country)
    relation = Customer.where(id: alice.id)

    csv = described_class.new(CsvCustomerDashboard.new, relation).to_csv
    table = CSV.parse(csv, headers: true)

    expect(table.headers).to eq(["Id", "Name", "Email", "Territory"])
    expect(table.first["Id"]).to eq(alice.id.to_s)
    expect(table.first["Name"]).to eq("Alice, Inc.")
    expect(table.first["Email"]).to eq("alice@example.com")
    expect(table.first["Territory"]).to eq("Canada")
  end

  it "lets dashboards customize exported attributes and values" do
    dashboard_class = Class.new(CsvCustomerDashboard) do
      def csv_attributes
        %i[name email]
      end

      def attribute_label(attribute, context = nil)
        return "Email address" if attribute == :email && context == :csv

        super
      end

      def csv_value(attribute, value, _resource)
        attribute == :email ? value.upcase : value
      end
    end

    customer = create_customer(name: "CSV Custom", email: "csv-custom@example.com")
    csv = described_class.new(dashboard_class.new, Customer.where(id: customer.id)).to_csv
    table = CSV.parse(csv, headers: true)

    expect(table.headers).to eq(["Name", "Email address"])
    expect(table.first["Email address"]).to eq("CSV-CUSTOM@EXAMPLE.COM")
  end
end
