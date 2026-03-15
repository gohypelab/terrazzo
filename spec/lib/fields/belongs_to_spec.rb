require "spec_helper"

RSpec.describe SuperAdmin::Field::BelongsTo do
  describe ".eager_load?" do
    it "returns true" do
      expect(described_class.eager_load?).to be true
    end
  end

  describe ".associative?" do
    it "returns true" do
      expect(described_class.associative?).to be true
    end
  end

  describe "#serialize_value" do
    let(:customer) { create_customer(name: "Alice") }
    let(:order) { create_order(customer: customer) }

    it "returns { id, display } for :index" do
      field = described_class.new(:customer, nil, :index, resource: order)
      result = field.serialize_value(:index)
      expect(result[:id]).to eq(customer.id)
      expect(result[:display]).to eq("Alice")
    end

    it "returns { id, display } for :show" do
      field = described_class.new(:customer, nil, :show, resource: order)
      result = field.serialize_value(:show)
      expect(result[:id]).to eq(customer.id)
      expect(result[:display]).to eq("Alice")
    end

    it "returns foreign key value for :form" do
      field = described_class.new(:customer, nil, :form, resource: order)
      result = field.serialize_value(:form)
      expect(result).to eq(customer.id)
    end

    it "returns nil when association is nil" do
      order = ::Order.new
      field = described_class.new(:customer, nil, :index, resource: order)
      expect(field.serialize_value(:index)).to be_nil
    end
  end

  describe "#serializable_options" do
    it "includes resourceOptions" do
      customer = create_customer(name: "Alice")
      order = ::Order.new(customer: customer)
      field = described_class.new(:customer, nil, :form, resource: order)
      opts = field.serializable_options
      expect(opts[:resourceOptions]).to be_an(Array)
      expect(opts[:resourceOptions].first).to eq(["Alice", customer.id])
    end
  end

  describe ".permitted_attribute" do
    it "returns foreign key name" do
      expect(described_class.permitted_attribute(:customer)).to eq(:customer_id)
    end
  end
end
