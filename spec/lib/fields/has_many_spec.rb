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
      expect(result[:currentPage]).to eq(1)
      expect(result[:totalPages]).to eq(1)
      expect(result[:perPage]).to eq(5)
    end

    it "paginates to the requested page" do
      6.times { create_order(customer: customer) }
      field = described_class.new(:orders, nil, :show, resource: customer, options: { per_page: 3, _page: 2 })
      result = field.serialize_value(:show)
      expect(result[:rows].length).to eq(3)
      expect(result[:total]).to eq(8)
      expect(result[:currentPage]).to eq(2)
      expect(result[:totalPages]).to eq(3)
      expect(result[:perPage]).to eq(3)
    end

    it "honors legacy :limit option as per_page fallback" do
      field = described_class.new(:orders, nil, :show, resource: customer, options: { limit: 2 })
      result = field.serialize_value(:show)
      expect(result[:perPage]).to eq(2)
      expect(result[:rows].length).to eq(2)
    end

    it "clamps _page < 1 to 1" do
      field = described_class.new(:orders, nil, :show, resource: customer, options: { _page: -5 })
      result = field.serialize_value(:show)
      expect(result[:currentPage]).to eq(1)
    end

    it "uses default per_page of 5" do
      field = described_class.new(:orders, nil, :show, resource: customer)
      result = field.serialize_value(:show)
      expect(result[:perPage]).to eq(5)
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
