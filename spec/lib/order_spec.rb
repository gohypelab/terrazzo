require "spec_helper"

RSpec.describe Terrazzo::Order do
  let(:dashboard) { CustomerDashboard.new }

  before do
    Customer.delete_all
    create_customer(name: "Charlie", email: "c@test.com")
    create_customer(name: "Alice", email: "a@test.com")
    create_customer(name: "Bob", email: "b@test.com")
  end

  describe "#apply" do
    it "returns relation unchanged when no params" do
      order = described_class.new
      result = order.apply(Customer.all, dashboard)
      expect(result.count).to eq(3)
    end

    it "applies ascending order" do
      order = described_class.new(attribute: :name, direction: "asc")
      result = order.apply(Customer.all, dashboard)
      expect(result.map(&:name)).to eq(["Alice", "Bob", "Charlie"])
    end

    it "applies descending order" do
      order = described_class.new(attribute: :name, direction: "desc")
      result = order.apply(Customer.all, dashboard)
      expect(result.map(&:name)).to eq(["Charlie", "Bob", "Alice"])
    end
  end

  describe "#order_params_for" do
    it "toggles asc to desc for current attribute" do
      order = described_class.new(attribute: :name, direction: "asc")
      params = order.order_params_for(:name)
      expect(params[:direction]).to eq("desc")
    end

    it "toggles desc to asc for current attribute" do
      order = described_class.new(attribute: :name, direction: "desc")
      params = order.order_params_for(:name)
      expect(params[:direction]).to eq("asc")
    end

    it "defaults to asc for different attribute" do
      order = described_class.new(attribute: :name, direction: "desc")
      params = order.order_params_for(:email)
      expect(params[:direction]).to eq("asc")
    end
  end

  describe "#ordered_by?" do
    it "returns true for current sort attribute" do
      order = described_class.new(attribute: :name, direction: "asc")
      expect(order.ordered_by?(:name)).to be true
    end

    it "returns false for different attribute" do
      order = described_class.new(attribute: :name, direction: "asc")
      expect(order.ordered_by?(:email)).to be false
    end
  end
end
