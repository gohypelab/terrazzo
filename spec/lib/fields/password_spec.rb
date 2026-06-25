require "spec_helper"

RSpec.describe Terrazzo::Field::Password do
  describe ".sortable?" do
    it "returns false" do
      expect(described_class.sortable?).to be false
    end
  end

  describe "#serialize_value" do
    it "masks present values outside forms" do
      field = described_class.new(:password, "secret", :show)

      expect(field.serialize_value(:show)).to eq(Terrazzo::Field::Password::MASKED)
    end

    it "does not serialize existing values into forms" do
      field = described_class.new(:password, "secret", :form)

      expect(field.serialize_value(:form)).to be_nil
    end
  end
end
