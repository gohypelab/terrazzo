require "spec_helper"

RSpec.describe SuperAdmin::ResourceResolver do
  describe "admin/customers" do
    let(:resolver) { described_class.new("admin/customers") }

    it "returns CustomerDashboard" do
      expect(resolver.dashboard_class).to eq(CustomerDashboard)
    end

    it "returns Customer" do
      expect(resolver.resource_class).to eq(Customer)
    end

    it "returns :admin namespace" do
      expect(resolver.namespace).to eq(:admin)
    end

    it "returns 'Customer' as resource title" do
      expect(resolver.resource_title).to eq("Customer")
    end
  end
end
