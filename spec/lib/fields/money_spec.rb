require "spec_helper"

RSpec.describe Terrazzo::Field::Money do
  describe "#serialize_value" do
    it "converts Money-like objects to float via to_f" do
      money = double("Money", to_f: 19.99)
      field = described_class.new(:price, money)
      expect(field.serialize_value(:index)).to eq(19.99)
    end

    it "returns nil for nil data" do
      field = described_class.new(:price, nil)
      expect(field.serialize_value(:index)).to be_nil
    end

    it "passes through plain numeric values" do
      field = described_class.new(:price, 42.5)
      expect(field.serialize_value(:index)).to eq(42.5)
    end
  end

  describe "#serializable_options" do
    it "defaults to 2 decimal places" do
      field = described_class.new(:price, 10)
      expect(field.serializable_options[:decimals]).to eq(2)
    end

    it "allows overriding decimals" do
      field = described_class.new(:price, 10, nil, options: { decimals: 0 })
      expect(field.serializable_options[:decimals]).to eq(0)
    end

    it "includes prefix and suffix when configured" do
      field = described_class.new(:price, 10, nil, options: {
        prefix: "$", suffix: "CAD"
      })
      opts = field.serializable_options
      expect(opts[:prefix]).to eq("$")
      expect(opts[:suffix]).to eq("CAD")
      expect(opts[:decimals]).to eq(2)
    end
  end

  describe ".field_type" do
    it "returns 'number' to reuse the NumberField React component" do
      expect(described_class.field_type).to eq("number")
    end
  end
end
