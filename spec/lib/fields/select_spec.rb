require "spec_helper"

RSpec.describe Terrazzo::Field::Select do
  describe "#serializable_options" do
    it "includes selectableOptions from array collection" do
      field = described_class.new(:kind, "vip", nil, options: {
        collection: %w[standard vip]
      })
      opts = field.serializable_options(:form)[:selectableOptions]
      expect(opts).to eq([["Standard", "standard"], ["Vip", "vip"]])
    end

    it "handles callable collection" do
      field = described_class.new(:kind, "vip", nil, options: {
        collection: ->(_resource) { %w[a b c] }
      })
      opts = field.serializable_options(:form)[:selectableOptions]
      expect(opts).to eq([["A", "a"], ["B", "b"], ["C", "c"]])
    end

    it "returns empty array when no collection" do
      field = described_class.new(:kind, "vip")
      expect(field.serializable_options(:form)[:selectableOptions]).to eq([])
    end

    it "excludes selectableOptions on non-form pages" do
      field = described_class.new(:kind, "vip", nil, options: {
        collection: %w[standard vip]
      })
      expect(field.serializable_options).to eq({})
      expect(field.serializable_options(:show)).to eq({})
    end
  end
end
