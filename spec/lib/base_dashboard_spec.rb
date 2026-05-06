require "spec_helper"

# Use unique names to avoid collisions with example app dashboards
class SpecCustomerDashboard < Terrazzo::BaseDashboard
  def self.model
    Customer
  end

  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::String,
    name: Terrazzo::Field::String.with_options(searchable: true),
    email: Terrazzo::Field::Email.with_options(searchable: true),
    email_subscriber: Terrazzo::Field::Boolean,
    kind: Terrazzo::Field::Select.with_options(collection: %w[standard vip]),
    orders: Terrazzo::Field::HasMany,
    territory: Terrazzo::Field::BelongsTo,
    created_at: Terrazzo::Field::DateTime,
    updated_at: Terrazzo::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name email kind territory].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name email email_subscriber kind orders territory created_at updated_at].freeze
  FORM_ATTRIBUTES = %i[name email email_subscriber kind territory].freeze
end

class SpecOrderDashboard < Terrazzo::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Terrazzo::Field::String,
    customer: Terrazzo::Field::BelongsTo,
    address_line_one: Terrazzo::Field::String,
    created_at: Terrazzo::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id customer address_line_one].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id customer address_line_one created_at].freeze
  FORM_ATTRIBUTES = %i[customer address_line_one].freeze
  FORM_ATTRIBUTES_NEW = %i[customer address_line_one].freeze
  FORM_ATTRIBUTES_EDIT = %i[address_line_one].freeze
end

RSpec.describe Terrazzo::BaseDashboard do
  let(:dashboard) { SpecCustomerDashboard.new }

  describe "#attribute_types" do
    it "returns the ATTRIBUTE_TYPES constant" do
      expect(dashboard.attribute_types).to eq(SpecCustomerDashboard::ATTRIBUTE_TYPES)
    end
  end

  describe "#attribute_type_for" do
    it "returns correct field class for known attribute" do
      type = dashboard.attribute_type_for(:name)
      field_class = type.is_a?(Terrazzo::Field::Deferred) ? type.deferred_class : type
      expect(field_class).to eq(Terrazzo::Field::String)
    end

    it "raises error for unknown attribute" do
      expect { dashboard.attribute_type_for(:unknown) }.to raise_error(/Unknown attribute/)
    end
  end

  describe "#form_attributes" do
    it "returns FORM_ATTRIBUTES with no action" do
      expect(dashboard.form_attributes).to eq(%i[name email email_subscriber kind territory])
    end

    context "with action-specific constants" do
      let(:order_dashboard) { SpecOrderDashboard.new }

      it "returns FORM_ATTRIBUTES_NEW for 'create'" do
        expect(order_dashboard.form_attributes("create")).to eq(%i[customer address_line_one])
      end

      it "returns FORM_ATTRIBUTES_EDIT for 'update'" do
        expect(order_dashboard.form_attributes("update")).to eq(%i[address_line_one])
      end
    end
  end

  describe "#collection_attributes" do
    it "returns array as-is" do
      expect(dashboard.collection_attributes).to eq(%i[id name email kind territory])
    end
  end

  describe "#show_page_attributes" do
    it "returns SHOW_PAGE_ATTRIBUTES" do
      expect(dashboard.show_page_attributes).to eq(
        %i[id name email email_subscriber kind orders territory created_at updated_at]
      )
    end
  end

  describe "#permitted_attributes" do
    it "maps through field types' permitted_attribute" do
      permitted = dashboard.permitted_attributes
      expect(permitted).to include(:name)
      expect(permitted).to include(:email)
      # territory uses foreign_key: :country_code on the Customer model
      expect(permitted).to include(:country_code)
    end
  end

  describe "#search_attributes" do
    it "returns only attributes where searchable? is true" do
      searchable = dashboard.search_attributes
      expect(searchable).to include(:name)
      expect(searchable).to include(:email)
      expect(searchable).not_to include(:id)
      expect(searchable).not_to include(:email_subscriber)
    end
  end

  describe "#display_resource" do
    it 'returns "ClassName #id" by default' do
      customer = create_customer(name: "Alice")
      expect(dashboard.display_resource(customer)).to eq("Customer ##{customer.id}")
    end
  end

  describe "#collection_includes" do
    it "returns eager-loadable attributes that appear in COLLECTION_ATTRIBUTES" do
      includes = dashboard.collection_includes
      expect(includes).to include(:territory)
      expect(includes).not_to include(:orders)   # eager_load? true but not in COLLECTION_ATTRIBUTES
      expect(includes).not_to include(:name)     # in COLLECTION_ATTRIBUTES but not eager_load?
    end
  end

  describe ".model" do
    it "derives model class from dashboard name" do
      expect(CustomerDashboard.model).to eq(Customer)
    end
  end

  describe ".resource_name" do
    it "returns model's human name" do
      expect(CustomerDashboard.resource_name).to eq("Customer")
    end
  end
end
