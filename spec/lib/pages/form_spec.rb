require "spec_helper"

RSpec.describe SuperAdmin::Page::Form do
  let(:customer) { Customer.new }

  describe "#attributes" do
    it "returns FORM_ATTRIBUTES fields with no action" do
      dashboard = SpecCustomerDashboard.new
      page = described_class.new(dashboard, customer)
      attrs = page.attributes
      expect(attrs.map(&:attribute)).to eq(%i[name email email_subscriber kind territory])
    end

    context "with action-specific constants" do
      let(:order_dashboard) { SpecOrderDashboard.new }
      let(:order) { Order.new }

      it "returns NEW-specific fields for 'create'" do
        page = described_class.new(order_dashboard, order)
        attrs = page.attributes("create")
        expect(attrs.map(&:attribute)).to eq(%i[customer address_line_one])
      end

      it "returns EDIT-specific fields for 'update'" do
        page = described_class.new(order_dashboard, order)
        attrs = page.attributes("update")
        expect(attrs.map(&:attribute)).to eq(%i[address_line_one])
      end
    end
  end
end
