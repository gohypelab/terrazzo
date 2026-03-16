require "spec_helper"

RSpec.describe Terrazzo::Search do
  let(:dashboard) { CustomerDashboard.new }

  before do
    Customer.delete_all
    create_customer(name: "Alice Smith", email: "alice@example.com")
    create_customer(name: "Bob Jones", email: "bob@example.com")
    create_customer(name: "Charlie Smith", email: "charlie@example.com")
  end

  describe "#run" do
    it "returns all records for blank term" do
      search = described_class.new(Customer.all, dashboard, nil)
      expect(search.run.count).to eq(3)
    end

    it "returns all records for empty string term" do
      search = described_class.new(Customer.all, dashboard, "")
      expect(search.run.count).to eq(3)
    end

    it "filters by LIKE on searchable string fields" do
      search = described_class.new(Customer.all, dashboard, "Smith")
      results = search.run
      expect(results.count).to eq(2)
      expect(results.map(&:name)).to contain_exactly("Alice Smith", "Charlie Smith")
    end

    it "search is case-insensitive" do
      search = described_class.new(Customer.all, dashboard, "alice")
      results = search.run
      expect(results.count).to eq(1)
      expect(results.first.name).to eq("Alice Smith")
    end

    it "searches across multiple searchable fields" do
      search = described_class.new(Customer.all, dashboard, "bob@example")
      results = search.run
      expect(results.count).to eq(1)
      expect(results.first.name).to eq("Bob Jones")
    end
  end
end
