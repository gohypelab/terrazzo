require "spec_helper"

RSpec.describe SuperAdmin::Field::Select do
  describe "#serializable_options" do
    it "includes selectableOptions from array collection" do
      field = described_class.new(:kind, "vip", nil, options: {
        collection: %w[standard vip]
      })
      opts = field.serializable_options[:selectableOptions]
      expect(opts).to eq([["Standard", "standard"], ["Vip", "vip"]])
    end

    it "handles callable collection" do
      field = described_class.new(:kind, "vip", nil, options: {
        collection: ->(_resource) { %w[a b c] }
      })
      opts = field.serializable_options[:selectableOptions]
      expect(opts).to eq([["A", "a"], ["B", "b"], ["C", "c"]])
    end

    it "returns empty array when no collection" do
      field = described_class.new(:kind, "vip")
      expect(field.serializable_options[:selectableOptions]).to eq([])
    end
  end
end
