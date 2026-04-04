require "spec_helper"

RSpec.describe Terrazzo::Field::Number do
  describe "#serialize_value" do
    it "returns raw number" do
      field = described_class.new(:price, 42.5)
      expect(field.serialize_value(:index)).to eq(42.5)
    end

    context "with format option" do
      it "formats as currency" do
        field = described_class.new(:price, 1234.5, nil, options: {
          format: { formatter: :number_to_currency, formatter_options: { unit: "$" } }
        })
        expect(field.serialize_value(:index)).to eq("$1,234.50")
      end

      it "formats as percentage" do
        field = described_class.new(:rate, 75.5, nil, options: {
          format: { formatter: :number_to_percentage, formatter_options: { precision: 1 } }
        })
        expect(field.serialize_value(:show)).to eq("75.5%")
      end

      it "applies multiplier before formatting" do
        field = described_class.new(:price, 100, nil, options: {
          multiplier: 0.01,
          format: { formatter: :number_to_currency, formatter_options: { unit: "$" } }
        })
        expect(field.serialize_value(:index)).to eq("$1.00")
      end

      it "returns raw value for :form" do
        field = described_class.new(:price, 1234.5, nil, options: {
          format: { formatter: :number_to_currency, formatter_options: {} }
        })
        expect(field.serialize_value(:form)).to eq(1234.5)
      end
    end

    context "with multiplier option" do
      let(:field) { described_class.new(:size_bytes, 2048, nil, options: { multiplier: 0.001 }) }

      it "applies multiplier for :index" do
        expect(field.serialize_value(:index)).to be_within(0.0001).of(2.048)
      end

      it "applies multiplier for :show" do
        expect(field.serialize_value(:show)).to be_within(0.0001).of(2.048)
      end

      it "returns raw value for :form" do
        expect(field.serialize_value(:form)).to eq(2048)
      end

      it "returns nil when data is nil" do
        field = described_class.new(:size_bytes, nil, nil, options: { multiplier: 0.001 })
        expect(field.serialize_value(:index)).to be_nil
      end
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
