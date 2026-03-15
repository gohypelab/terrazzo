require "spec_helper"

RSpec.describe SuperAdmin::Field::Number do
  describe "#serialize_value" do
    it "returns raw number" do
      field = described_class.new(:price, 42.5)
      expect(field.serialize_value(:index)).to eq(42.5)
    end
  end

  describe "#serializable_options" do
    it "includes prefix, suffix, decimals when configured" do
      field = described_class.new(:price, 42.5, nil, options: {
        prefix: "$", suffix: "USD", decimals: 2
      })
      expect(field.serializable_options).to eq(
        prefix: "$", suffix: "USD", decimals: 2
      )
    end

    it "returns empty hash when no options configured" do
      field = described_class.new(:price, 42.5)
      expect(field.serializable_options).to eq({})
    end
  end
end
