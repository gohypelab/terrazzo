require "spec_helper"

RSpec.describe Terrazzo::Field::HasMany do
  describe ".associative?" do
    it "returns true" do
      expect(described_class.associative?).to be true
    end
  end

  describe ".sortable?" do
    it "returns false" do
      expect(described_class.sortable?).to be false
    end
  end

  describe "#serialize_value" do
    let(:customer) { create_customer(name: "Alice") }

    before do
      2.times { create_order(customer: customer) }
    end

    it "returns count for :index" do
      field = described_class.new(:orders, nil, :index, resource: customer)
      expect(field.serialize_value(:index)).to eq(2)
    end

    it "returns paginated hash for :show" do
      field = described_class.new(:orders, nil, :show, resource: customer)
      result = field.serialize_value(:show)
      expect(result).to be_a(Hash)
      expect(result[:items].length).to eq(2)
      expect(result[:items].first).to have_key(:id)
      expect(result[:items].first).to have_key(:display)
      expect(result[:total]).to eq(2)
      expect(result[:hasMore]).to be false
    end

    it "respects :limit option" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      result = field.serialize_value(:show)
      expect(result[:items].length).to eq(2)
      expect(result[:total]).to eq(5)
      expect(result[:hasMore]).to be true
    end

    it "uses default limit of 5" do
      expect(described_class.default_options[:limit]).to eq(5)
    end

    it "returns array of selected IDs for :form" do
      field = described_class.new(:orders, nil, :form, resource: customer)
      result = field.serialize_value(:form)
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result).to all(be_a(Integer))
    end
  end

  describe ".permitted_attribute" do
    it 'returns { "attr_ids" => [] }' do
      expect(described_class.permitted_attribute(:orders)).to eq({ "order_ids" => [] })
    end
  end
end
