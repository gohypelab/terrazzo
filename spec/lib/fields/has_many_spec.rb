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

    it "returns count and label for :index" do
      field = described_class.new(:orders, nil, :index, resource: customer)
      expect(field.serialize_value(:index)).to eq({ count: 2, label: "orders" })
    end

    it "singularizes label when count is 1" do
      customer2 = create_customer(name: "Bob")
      create_order(customer: customer2)
      field = described_class.new(:orders, nil, :index, resource: customer2)
      expect(field.serialize_value(:index)).to eq({ count: 1, label: "order" })
    end

    it "returns a nested table using associated dashboard's COLLECTION_ATTRIBUTES for :show" do
      field = described_class.new(:orders, nil, :show, resource: customer)
      result = field.serialize_value(:show)
      expect(result).to be_a(Hash)
      expect(result[:headers]).to be_an(Array)
      expect(result[:headers].map { |h| h[:attribute] }).to eq(%w[id address_line_one created_at])
      expect(result[:items].length).to eq(2)
      expect(result[:items].first).to have_key(:id)
      expect(result[:items].first).to have_key(:columns)
      expect(result[:total]).to eq(2)
      expect(result[:initialLimit]).to eq(5)
    end

    it "sends all items with initialLimit for frontend truncation" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      result = field.serialize_value(:show)
      expect(result[:items].length).to eq(5)
      expect(result[:total]).to eq(5)
      expect(result[:initialLimit]).to eq(2)
      expect(result[:headers]).to be_an(Array)
    end

    it "uses default limit of 5" do
      expect(described_class.default_options[:limit]).to eq(5)
    end

    it "returns array of selected IDs for :form" do
      field = described_class.new(:orders, nil, :form, resource: customer)
      result = field.serialize_value(:form)
      expect(result).to be_an(Array)
      expect(result.length).to eq(2)
      expect(result).to all(be_a(String))
    end
  end

  describe ".permitted_attribute" do
    it 'returns { "attr_ids" => [] }' do
      expect(described_class.permitted_attribute(:orders)).to eq({ "order_ids" => [] })
    end
  end
end
