require "spec_helper"

RSpec.describe Terrazzo::Field::Deferred do
  let(:deferred) { Terrazzo::Field::String.with_options(truncate: 10) }

  describe "delegation" do
    it "delegates searchable? to wrapped field class" do
      expect(deferred.searchable?).to eq(Terrazzo::Field::String.searchable?)
    end

    it "delegates sortable? to wrapped field class" do
      expect(deferred.sortable?).to eq(Terrazzo::Field::String.sortable?)
    end

    it "delegates eager_load? to wrapped field class" do
      expect(deferred.eager_load?).to eq(Terrazzo::Field::String.eager_load?)
    end

    it "delegates associative? to wrapped field class" do
      expect(deferred.associative?).to eq(Terrazzo::Field::String.associative?)
    end

    it "delegates field_type to wrapped field class" do
      expect(deferred.field_type).to eq("string")
    end
  end

  describe "#new" do
    it "merges options when instantiated" do
      field = deferred.new(:name, "a" * 50)
      expect(field.options[:truncate]).to eq(10)
      result = field.serialize_value(:index)
      expect(result.length).to be <= 13
    end
  end

  describe "#with_options" do
    it "chains options" do
      chained = deferred.with_options(prefix: "$")
      expect(chained.options).to eq(truncate: 10, prefix: "$")
    end
  end
end
