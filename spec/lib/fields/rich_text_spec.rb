require "spec_helper"

RSpec.describe Terrazzo::Field::RichText do
  describe ".searchable?" do
    it "returns false" do
      expect(described_class.searchable?).to be false
    end
  end

  describe ".sortable?" do
    it "returns false" do
      expect(described_class.sortable?).to be false
    end
  end

  describe ".eager_load?" do
    it "returns true" do
      expect(described_class.eager_load?).to be true
    end
  end

  describe ".eager_load_association" do
    it "uses the rich text association when it exists" do
      expect(described_class.eager_load_association(:banner, Product)).to eq(:rich_text_banner)
    end
  end
end
