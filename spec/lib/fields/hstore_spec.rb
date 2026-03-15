require "spec_helper"

RSpec.describe SuperAdmin::Field::Hstore do
  describe "#field_type" do
    it "returns hstore" do
      field = described_class.new(:metadata, {})
      expect(field.field_type).to eq("hstore")
    end
  end

  describe "#serialize_value" do
    context "with :index mode" do
      it "returns a truncated key-value preview" do
        field = described_class.new(:metadata, { "color" => "red", "size" => "M" })
        expect(field.serialize_value(:index)).to eq("color: red, size: M")
      end

      it "truncates long previews" do
        field = described_class.new(:metadata, { "color" => "red" }, nil, options: { truncate: 5 })
        expect(field.serialize_value(:index)).to eq("color...")
      end

      it "returns empty string for empty hash" do
        field = described_class.new(:metadata, {})
        expect(field.serialize_value(:index)).to eq("")
      end

      it "returns empty string for nil data" do
        field = described_class.new(:metadata, nil)
        expect(field.serialize_value(:index)).to eq("")
      end
    end

    context "with :show mode" do
      it "returns the full hash" do
        hash = { "color" => "red", "size" => "M" }
        field = described_class.new(:metadata, hash)
        expect(field.serialize_value(:show)).to eq(hash)
      end

      it "returns empty hash for nil data" do
        field = described_class.new(:metadata, nil)
        expect(field.serialize_value(:show)).to eq({})
      end
    end

    context "with :form mode" do
      it "returns the full hash" do
        hash = { "color" => "red", "size" => "M" }
        field = described_class.new(:metadata, hash)
        expect(field.serialize_value(:form)).to eq(hash)
      end

      it "returns empty hash for nil data" do
        field = described_class.new(:metadata, nil)
        expect(field.serialize_value(:form)).to eq({})
      end
    end
  end

  describe ".sortable?" do
    it "returns false" do
      expect(described_class.sortable?).to be false
    end
  end

  describe ".searchable?" do
    it "returns false" do
      expect(described_class.searchable?).to be false
    end
  end

  describe ".permitted_attribute" do
    it "returns the attribute name as a symbol" do
      expect(described_class.permitted_attribute(:metadata)).to eq(:metadata)
    end
  end

  describe ".transform_param" do
    it "parses a JSON string into a hash" do
      result = described_class.transform_param('{"color":"red","size":"M"}')
      expect(result).to eq({ "color" => "red", "size" => "M" })
    end

    it "returns a hash as-is" do
      hash = { "color" => "red" }
      expect(described_class.transform_param(hash)).to eq(hash)
    end

    it "returns empty hash for blank string" do
      expect(described_class.transform_param("")).to eq({})
    end

    it "returns empty hash for nil" do
      expect(described_class.transform_param(nil)).to eq({})
    end

    it "returns empty hash for invalid JSON" do
      expect(described_class.transform_param("not json")).to eq({})
    end
  end

  describe ".with_options" do
    it "returns a Deferred with options" do
      deferred = described_class.with_options(truncate: 50)
      expect(deferred).to be_a(SuperAdmin::Field::Deferred)
      expect(deferred.options).to eq(truncate: 50)
    end
  end
end
