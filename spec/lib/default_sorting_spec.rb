require "spec_helper"

RSpec.describe Terrazzo::Order, "default sorting" do
  it "works with nil attribute (no default)" do
    order = described_class.new(attribute: nil, direction: nil)
    expect(order.attribute).to be_nil
  end

  it "uses provided attribute over nil" do
    order = described_class.new(attribute: :name, direction: "asc")
    expect(order.attribute).to eq(:name)
    expect(order.direction).to eq(:asc)
  end

  it "normalizes invalid direction to :asc" do
    order = described_class.new(attribute: :name, direction: "invalid")
    expect(order.direction).to eq(:asc)
  end

  it "returns relation unchanged when attribute is nil" do
    Customer.delete_all
    create_customer(name: "Bob")
    create_customer(name: "Alice")

    dashboard = CustomerDashboard.new
    order = described_class.new(attribute: nil, direction: :asc)
    result = order.apply(Customer.all, dashboard)
    expect(result.count).to eq(2)
  end
end
