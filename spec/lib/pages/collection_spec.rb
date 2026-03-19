require "spec_helper"

RSpec.describe Terrazzo::Page::Collection do
  let(:dashboard) { CustomerDashboard.new }
  let(:order) { Terrazzo::Order.new(attribute: :name, direction: "asc") }
  let(:page) { described_class.new(dashboard, Customer, order: order) }

  describe "#attribute_names" do
    it "returns dashboard's collection_attributes" do
      expect(page.attribute_names).to eq(%i[id name email kind territory])
    end
  end

  describe "#ordered_by?" do
    it "returns true for current sort attribute" do
      expect(page.ordered_by?(:name)).to be true
    end

    it "returns false for other attributes" do
      expect(page.ordered_by?(:email)).to be false
    end
  end

  describe "#order_params_for" do
    it "returns toggled sort direction params" do
      params = page.order_params_for(:name)
      expect(params[:order]).to eq("name")
      expect(params[:direction]).to eq("desc")
    end
  end
end
