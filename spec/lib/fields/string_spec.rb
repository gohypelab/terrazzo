require "spec_helper"

RSpec.describe Terrazzo::Field::String do
  describe ".searchable?" do
    it "returns true" do
      expect(described_class.searchable?).to be true
    end
  end

  describe "#serialize_value" do
    it "truncates to 50 chars by default for :index" do
      long_string = "a" * 100
      field = described_class.new(:name, long_string)
      result = field.serialize_value(:index)
      expect(result.length).to be <= 53 # 50 + "..."
      expect(result).to end_with("...")
    end

    it "truncates to custom length with truncate option" do
      long_string = "a" * 100
      field = described_class.new(:name, long_string, nil, options: { truncate: 10 })
      result = field.serialize_value(:index)
      expect(result.length).to be <= 13
    end

    it "returns full string for :show" do
      long_string = "a" * 100
      field = described_class.new(:name, long_string)
      expect(field.serialize_value(:show)).to eq(long_string)
    end

    it "returns full string for :form" do
      long_string = "a" * 100
      field = described_class.new(:name, long_string)
      expect(field.serialize_value(:form)).to eq(long_string)
    end

    it "handles nil data" do
      field = described_class.new(:name, nil)
      expect(field.serialize_value(:index)).to eq("")
    end
  end
end
