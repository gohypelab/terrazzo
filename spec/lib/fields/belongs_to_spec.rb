require "spec_helper"

RSpec.describe Terrazzo::Field::BelongsTo do
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
      expect(result[:id]).to eq(customer.id.to_s)
      expect(result[:display]).to eq("Alice")
    end

    it "uses the associated dashboard display_resource for display values" do
      allow_any_instance_of(CustomerDashboard).to receive(:display_resource)
        .with(customer)
        .and_return("Customer display: Alice")

      field = described_class.new(:customer, nil, :show, resource: order)
      result = field.serialize_value(:show)

      expect(result[:display]).to eq("Customer display: Alice")
    end

    it "uses the record display fallback when the associated dashboard does not override display_resource" do
      stub_const("CountryDashboard", Class.new(Terrazzo::BaseDashboard))
      country = create_country(code: "CA", name: "Canada")
      customer = create_customer(name: "Alice", country: country)
      field = described_class.new(:territory, nil, :show, resource: customer)
      result = field.serialize_value(:show)

      expect(result[:display]).to eq("Canada")
    end

    it "returns { id, display } for :show" do
      field = described_class.new(:customer, nil, :show, resource: order)
      result = field.serialize_value(:show)
      expect(result[:id]).to eq(customer.id.to_s)
      expect(result[:display]).to eq("Alice")
    end

    it "returns foreign key value for :form" do
      field = described_class.new(:customer, nil, :form, resource: order)
      result = field.serialize_value(:form)
      expect(result).to eq(customer.id.to_s)
    end

    it "returns nil when association is nil" do
      order = ::Order.new
      field = described_class.new(:customer, nil, :index, resource: order)
      expect(field.serialize_value(:index)).to be_nil
    end
  end

  describe "#serializable_options" do
    it "includes resourceOptions on :form" do
      customer = create_customer(name: "Alice")
      order = ::Order.new(customer: customer)
      field = described_class.new(:customer, nil, :form, resource: order)
      opts = field.serializable_options(:form)
      expect(opts[:resourceOptions]).to be_an(Array)
      expect(opts[:resourceOptions]).to include(["Alice", customer.id.to_s])
    end

    it "excludes resourceOptions on non-form pages" do
      create_customer(name: "Alice")
      order = create_order
      field = described_class.new(:customer, nil, :show, resource: order)
      expect(field.serializable_options).to eq({})
      expect(field.serializable_options(:show)).to eq({})
    end
  end

  describe "#serializable_options with order" do
    it "sorts candidate resources by the specified attribute" do
      create_customer(name: "Charlie")
      create_customer(name: "Alice")
      create_customer(name: "Bob")
      order = create_order
      field = described_class.new(:customer, nil, :form, resource: order, options: {
        order: :name
      })
      opts = field.serializable_options(:form)
      names = opts[:resourceOptions].map(&:first)
      expect(names).to eq(names.sort)
    end
  end

  describe ".permitted_attribute" do
    it "returns foreign key name" do
      expect(described_class.permitted_attribute(:customer)).to eq(:customer_id)
    end
  end
end
