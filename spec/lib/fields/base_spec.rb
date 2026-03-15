require "spec_helper"

RSpec.describe SuperAdmin::Field::Base do
  describe "#field_type" do
    it "returns underscored class name" do
      field = described_class.new(:name, "test")
      expect(field.field_type).to eq("base")
    end
  end

  describe "#serialize_value" do
    let(:field) { described_class.new(:name, "test") }

    it "returns data for :index" do
      expect(field.serialize_value(:index)).to eq("test")
    end

    it "returns data for :show" do
      expect(field.serialize_value(:show)).to eq("test")
    end

    it "returns data for :form" do
      expect(field.serialize_value(:form)).to eq("test")
    end
  end

  describe "#serializable_options" do
    it "returns empty hash by default" do
      field = described_class.new(:name, "test")
      expect(field.serializable_options).to eq({})
    end
  end

  describe "#required?" do
    it "returns true when model has presence validator" do
      customer = Customer.new
      field = described_class.new(:name, nil, :form, resource: customer)
      expect(field.required?).to be true
    end

    it "returns false when no presence validator" do
      customer = Customer.new
      field = described_class.new(:email_subscriber, nil, :form, resource: customer)
      expect(field.required?).to be false
    end
  end

  describe ".searchable?" do
    it "returns false by default" do
      expect(described_class.searchable?).to be false
    end
  end

  describe ".sortable?" do
    it "returns true by default" do
      expect(described_class.sortable?).to be true
    end
  end

  describe ".eager_load?" do
    it "returns false by default" do
      expect(described_class.eager_load?).to be false
    end
  end

  describe ".with_options" do
    it "returns Deferred wrapping the field class" do
      deferred = described_class.with_options(truncate: 10)
      expect(deferred).to be_a(SuperAdmin::Field::Deferred)
      expect(deferred.deferred_class).to eq(described_class)
      expect(deferred.options).to eq(truncate: 10)
    end
  end

  describe ".permitted_attribute" do
    it "returns attribute name as symbol" do
      expect(described_class.permitted_attribute(:name)).to eq(:name)
    end
  end
end
