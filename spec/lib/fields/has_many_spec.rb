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
      expect(result[:rows].length).to eq(2)
      expect(result[:rows].first).to have_key(:id)
      expect(result[:rows].first).to have_key(:cells)
      expect(result[:total]).to eq(2)
      expect(result[:initialLimit]).to eq(5)
    end

    it "limits rows to the specified limit for server-side pagination" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      result = field.serialize_value(:show)
      expect(result[:rows].length).to eq(2)
      expect(result[:total]).to eq(5)
      expect(result[:initialLimit]).to eq(2)
      expect(result[:offset]).to eq(0)
      expect(result[:headers]).to be_an(Array)
    end

    it "exposes show_records with only the limited records" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      field.serialize_value(:show)
      expect(field.show_records.length).to eq(2)
    end

    it "paginates with show_offset" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      field.show_offset = 2
      result = field.serialize_value(:show)
      expect(result[:rows].length).to eq(2)
      expect(result[:total]).to eq(5)
      expect(result[:offset]).to eq(2)
    end

    it "returns remaining records on the last page" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      field.show_offset = 4
      result = field.serialize_value(:show)
      expect(result[:rows].length).to eq(1)
      expect(result[:total]).to eq(5)
      expect(result[:offset]).to eq(4)
    end

    it "loads all records when limit is 0" do
      3.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 0 })
      result = field.serialize_value(:show)
      expect(result[:rows].length).to eq(5)
      expect(result[:total]).to eq(5)
    end

    it "returns all records when total is less than limit" do
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 10 })
      result = field.serialize_value(:show)
      expect(result[:rows].length).to eq(2)
      expect(result[:total]).to eq(2)
      expect(result[:initialLimit]).to eq(10)
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

  describe "#serialize_value with sort_by and direction" do
    let(:customer) { create_customer(name: "Alice") }

    it "sorts related items by the specified attribute ascending" do
      order_b = create_order(customer: customer, address_city: "Boston")
      order_a = create_order(customer: customer, address_city: "Atlanta")
      field = described_class.new(:orders, nil, :show, resource: customer, options: {
        sort_by: :address_city, direction: :asc
      })
      result = field.serialize_value(:show)
      ids = result[:rows].map { |i| i[:id] }
      expect(ids).to eq([order_a.id.to_s, order_b.id.to_s])
    end

    it "sorts related items descending" do
      order_b = create_order(customer: customer, address_city: "Boston")
      order_a = create_order(customer: customer, address_city: "Atlanta")
      field = described_class.new(:orders, nil, :show, resource: customer, options: {
        sort_by: :address_city, direction: :desc
      })
      result = field.serialize_value(:show)
      ids = result[:rows].map { |i| i[:id] }
      expect(ids).to eq([order_b.id.to_s, order_a.id.to_s])
    end

    it "defaults direction to :asc" do
      order_b = create_order(customer: customer, address_city: "Boston")
      order_a = create_order(customer: customer, address_city: "Atlanta")
      field = described_class.new(:orders, nil, :show, resource: customer, options: {
        sort_by: :address_city
      })
      result = field.serialize_value(:show)
      ids = result[:rows].map { |i| i[:id] }
      expect(ids).to eq([order_a.id.to_s, order_b.id.to_s])
    end
  end

  describe "#serializable_options" do
    it "excludes resourceOptions on non-form pages" do
      customer = create_customer(name: "Alice")
      field = described_class.new(:orders, nil, :show, resource: customer)
      expect(field.serializable_options).to eq({})
      expect(field.serializable_options(:show)).to eq({})
    end
  end

  describe ".permitted_attribute" do
    it 'returns { "attr_ids" => [] }' do
      expect(described_class.permitted_attribute(:orders)).to eq({ "order_ids" => [] })
    end
  end
end
