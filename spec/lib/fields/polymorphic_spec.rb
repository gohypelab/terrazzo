require "spec_helper"

RSpec.describe Terrazzo::Field::Polymorphic do
  describe ".sortable?" do
    it "returns false" do
      expect(described_class.sortable?).to be false
    end
  end

  describe ".eager_load?" do
    it "returns true" do
      expect(described_class.eager_load?).to be true
    end
  end

  describe "#serialize_value" do
    let(:customer) { create_customer(name: "Alice") }
    let(:log_entry) { LogEntry.create!(action: "login", loggable: customer) }

    it "returns { type, id, display } for :show" do
      field = described_class.new(:loggable, nil, :show, resource: log_entry)
      result = field.serialize_value(:show)
      expect(result[:type]).to eq("Customer")
      expect(result[:id]).to eq(customer.id.to_s)
      expect(result[:display]).to eq("Alice")
    end

    it "uses the associated dashboard display_resource for display values" do
      allow_any_instance_of(CustomerDashboard).to receive(:display_resource)
        .with(customer)
        .and_return("Customer display: Alice")

      field = described_class.new(:loggable, nil, :show, resource: log_entry)
      result = field.serialize_value(:show)

      expect(result[:display]).to eq("Customer display: Alice")
    end

    it "returns { type, id } for :form" do
      field = described_class.new(:loggable, nil, :form, resource: log_entry)
      result = field.serialize_value(:form)
      expect(result[:type]).to eq("Customer")
      expect(result[:id]).to eq(customer.id.to_s)
    end

    it "returns nil when association is nil" do
      log_entry = LogEntry.new
      field = described_class.new(:loggable, nil, :show, resource: log_entry)
      expect(field.serialize_value(:show)).to be_nil
    end
  end

  describe "#serializable_options" do
    it "excludes groupedOptions on non-form pages" do
      log_entry = LogEntry.create!(action: "test", loggable: create_customer(name: "Alice"))
      field = described_class.new(:loggable, nil, :show, resource: log_entry, options: {
        classes: ["Customer"]
      })
      expect(field.serializable_options).to eq({})
      expect(field.serializable_options(:show)).to eq({})
    end
  end

  describe "#serializable_options with order" do
    it "sorts candidate resources per class" do
      create_customer(name: "Charlie")
      create_customer(name: "Alice")
      create_customer(name: "Bob")
      log_entry = LogEntry.create!(action: "test", loggable: Customer.first)
      field = described_class.new(:loggable, nil, :form, resource: log_entry, options: {
        classes: ["Customer"],
        order: :name
      })
      opts = field.serializable_options(:form)
      names = opts[:groupedOptions]["Customer"].map(&:first)
      expect(names).to eq(names.sort)
    end
  end

  describe "#serializable_options with dashboard display names" do
    it "uses each candidate class dashboard display_resource" do
      allow_any_instance_of(CustomerDashboard).to receive(:display_resource) do |_dashboard, resource|
        "Customer display: #{resource.name}"
      end

      customer = create_customer(name: "Dashboard Alice")
      log_entry = LogEntry.create!(action: "test", loggable: customer)
      field = described_class.new(:loggable, nil, :form, resource: log_entry, options: {
        classes: ["Customer"],
      })

      options = field.serializable_options(:form)

      expect(options[:groupedOptions]["Customer"]).to include([
        "Customer display: Dashboard Alice",
        customer.id.to_s,
      ])
    end
  end

  describe ".permitted_attribute" do
    it "returns [:attr_type, :attr_id]" do
      expect(described_class.permitted_attribute(:loggable)).to eq([:loggable_type, :loggable_id])
    end
  end
end
