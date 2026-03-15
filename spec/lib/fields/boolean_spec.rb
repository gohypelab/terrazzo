require "spec_helper"

RSpec.describe SuperAdmin::Field::Boolean do
  describe "#serialize_value" do
    it "returns true" do
      field = described_class.new(:active, true)
      expect(field.serialize_value(:index)).to be true
    end

    it "returns false" do
      field = described_class.new(:active, false)
      expect(field.serialize_value(:index)).to be false
    end

    it "returns nil" do
      field = described_class.new(:active, nil)
      expect(field.serialize_value(:index)).to be_nil
    end
  end
end
