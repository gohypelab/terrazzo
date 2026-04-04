require "spec_helper"

RSpec.describe Terrazzo::Field::Polymorphic do
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
      opts = field.serializable_options
      names = opts[:groupedOptions]["Customer"].map(&:first)
      expect(names).to eq(names.sort)
    end
  end

  describe ".permitted_attribute" do
    it "returns [:attr_type, :attr_id]" do
      expect(described_class.permitted_attribute(:loggable)).to eq([:loggable_type, :loggable_id])
    end
  end
end
