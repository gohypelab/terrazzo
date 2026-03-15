require "spec_helper"

RSpec.describe SuperAdmin::Page::Show do
  let(:dashboard) { CustomerDashboard.new }
  let(:customer) { create_customer(name: "Alice") }
  let(:page) { described_class.new(dashboard, customer) }

  describe "#page_title" do
    it "returns dashboard's display_resource" do
      expect(page.page_title).to eq("Customer ##{customer.id}")
    end
  end

  describe "#attributes" do
    it "returns show_page_attributes as field instances" do
      attrs = page.attributes
      expect(attrs).to all(be_a(SuperAdmin::Field::Base))
      expect(attrs.map(&:attribute)).to eq(dashboard.show_page_attributes)
    end
  end
end
