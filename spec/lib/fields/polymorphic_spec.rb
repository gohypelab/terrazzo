require "spec_helper"

RSpec.describe SuperAdmin::Field::Polymorphic do
  describe "#serialize_value" do
    let(:customer) { create_customer(name: "Alice") }
    let(:log_entry) { LogEntry.create!(action: "login", loggable: customer) }

    it "returns { type, id, display } for :show" do
      field = described_class.new(:loggable, nil, :show, resource: log_entry)
      result = field.serialize_value(:show)
      expect(result[:type]).to eq("Customer")
      expect(result[:id]).to eq(customer.id)
      expect(result[:display]).to eq("Alice")
    end

    it "returns { type, id } for :form" do
      field = described_class.new(:loggable, nil, :form, resource: log_entry)
      result = field.serialize_value(:form)
      expect(result[:type]).to eq("Customer")
      expect(result[:id]).to eq(customer.id)
    end

    it "returns nil when association is nil" do
      log_entry = LogEntry.new
      field = described_class.new(:loggable, nil, :show, resource: log_entry)
      expect(field.serialize_value(:show)).to be_nil
    end
  end

  describe ".permitted_attribute" do
    it "returns [:attr_type, :attr_id]" do
      expect(described_class.permitted_attribute(:loggable)).to eq([:loggable_type, :loggable_id])
    end
  end
end
