require "spec_helper"

# Dashboard with filters for testing
class FilterTestDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::String,
    name: Terrazzo::Field::String,
    email: Terrazzo::Field::Email,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name email].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name email].freeze
  FORM_ATTRIBUTES = %i[name email].freeze

  COLLECTION_FILTERS = {
    recent: ->(resources) { resources.where("created_at > ?", 1.day.ago) },
    by_name: ->(resources, name) { resources.where(name: name) },
  }.freeze
end

class NoFilterDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::String,
    name: Terrazzo::Field::String,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name].freeze
  FORM_ATTRIBUTES = %i[name].freeze
end

RSpec.describe Terrazzo::Filter do
  let(:dashboard) { FilterTestDashboard.new }

  before do
    @customers = [
      create_customer(name: "Alice", email: "alice@example.com"),
      create_customer(name: "Bob", email: "bob@example.com"),
      create_customer(name: "Charlie", email: "charlie@example.com")
    ]
  end

  let(:scope) { Customer.where(id: @customers.map(&:id)) }

  describe "#run" do
    it "returns resources unchanged when no filter name" do
      filter = described_class.new(scope, dashboard, nil)
      expect(filter.run.count).to eq(3)
    end

    it "returns resources unchanged for unknown filter" do
      filter = described_class.new(scope, dashboard, :nonexistent)
      expect(filter.run.count).to eq(3)
    end

    it "applies 1-arity filter" do
      filter = described_class.new(scope, dashboard, :recent)
      result = filter.run
      expect(result.count).to eq(3) # all just created
    end

    it "applies 2-arity filter with value" do
      filter = described_class.new(scope, dashboard, :by_name, "Alice")
      result = filter.run
      expect(result.count).to eq(1)
      expect(result.first.name).to eq("Alice")
    end

    it "returns resources unchanged when dashboard has no COLLECTION_FILTERS" do
      no_filter_dashboard = NoFilterDashboard.new
      filter = described_class.new(scope, no_filter_dashboard, :anything)
      expect(filter.run.count).to eq(3)
    end
  end
end

RSpec.describe Terrazzo::BaseDashboard, "collection_filters" do
  it "returns COLLECTION_FILTERS hash when defined" do
    dashboard = FilterTestDashboard.new
    expect(dashboard.collection_filters.keys).to contain_exactly(:recent, :by_name)
  end

  it "returns empty hash when not defined" do
    dashboard = NoFilterDashboard.new
    expect(dashboard.collection_filters).to eq({})
  end

  it "builds filter options for filters that do not require values" do
    dashboard = FilterTestDashboard.new

    expect(dashboard.collection_filter_options).to eq([
      { label: "Recent", value: "recent" },
    ])
  end

  it "humanizes filter labels" do
    dashboard = FilterTestDashboard.new

    expect(dashboard.collection_filter_label(:by_name)).to eq("By name")
  end
end
