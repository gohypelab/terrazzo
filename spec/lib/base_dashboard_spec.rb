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

  describe "#attribute_label" do
    it "humanizes the attribute by default" do
      expect(dashboard.attribute_label(:email_subscriber)).to eq("Email subscriber")
    end
  end

  describe "#attribute_hint" do
    it "returns no hint by default" do
      expect(dashboard.attribute_hint(:email, :form)).to be_nil
    end
  end

  describe "#collection_cell_options" do
    it "returns no cell metadata by default" do
      customer = create_customer(name: "Alice")

      expect(dashboard.collection_cell_options(:name, customer)).to eq({})
    end
  end

  describe "#collection_header_options" do
    it "returns no header metadata by default" do
      expect(dashboard.collection_header_options(:name)).to eq({})
    end
  end

  describe "#collection_row_options" do
    it "returns no row metadata by default" do
      customer = create_customer(name: "Alice")

      expect(dashboard.collection_row_options(customer)).to eq({})
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

  describe "#includes_for_attributes" do
    it "returns eager-loadable attributes from the provided attributes" do
      includes = dashboard.includes_for_attributes([:orders, :name])
      expect(includes).to eq([:orders])
    end

    it "maps rich text fields to their Action Text association" do
      rich_text_dashboard = Class.new(Terrazzo::BaseDashboard) do
        def self.model
          Product
        end
      end
      rich_text_dashboard.const_set(:ATTRIBUTE_TYPES, {
        banner: Terrazzo::Field::RichText.with_options(truncate: 80),
      }.freeze)
      rich_text_dashboard.const_set(:COLLECTION_ATTRIBUTES, %i[banner].freeze)
      rich_text_dashboard.const_set(:SHOW_PAGE_ATTRIBUTES, %i[banner].freeze)
      rich_text_dashboard.const_set(:FORM_ATTRIBUTES, %i[banner].freeze)

      expect(rich_text_dashboard.new.includes_for_attributes([:banner])).to eq([:rich_text_banner])
    end
  end

  describe "#collection_toolbar_actions" do
    it "includes a CSV export action by default when a view context is available" do
      request = double("request", query_parameters: { "search" => "alice", "_page" => "2", "per_page" => "100" })
      view = double("view", request: request)
      allow(view).to receive(:url_for)
        .with({ "search" => "alice", format: :csv, only_path: true })
        .and_return("/admin/customers.csv?search=alice")

      expect(dashboard.collection_toolbar_actions(view)).to eq([
        {
          label: "Export CSV",
          url: "/admin/customers.csv?search=alice",
          sg_visit: false,
        },
      ])
    end

    it "returns no toolbar actions without a view context" do
      expect(dashboard.collection_toolbar_actions).to eq([])
    end
  end

  describe "#collection_item_actions" do
    it "includes the default row actions when a view context is available" do
      customer = create_customer(name: "Alice")
      view = double("view")
      allow(view).to receive(:collection_action_path).with(customer, :show).and_return("/admin/customers/1")
      allow(view).to receive(:collection_action_path).with(customer, :edit).and_return("/admin/customers/1/edit")
      allow(view).to receive(:collection_action_path).with(customer, :destroy).and_return("/admin/customers/1")

      expect(dashboard.collection_item_actions(customer, view)).to eq([
        { label: "Show", url: "/admin/customers/1" },
        { label: "Edit", url: "/admin/customers/1/edit" },
        {
          label: "Destroy",
          url: "/admin/customers/1",
          method: "delete",
          confirm: "Are you sure?"
        },
      ])
    end

    it "returns no row actions without a view context" do
      customer = Customer.new(name: "Alice")

      expect(dashboard.collection_item_actions(customer)).to eq([])
    end
  end

  describe "#layout_actions" do
    it "returns no page header actions by default" do
      customer = create_customer(name: "Alice")

      expect(dashboard.layout_actions(:show, double("view"), resource: customer)).to eq([])
    end
  end

  describe "#csv_export_enabled?" do
    it "is enabled by default" do
      expect(dashboard.csv_export_enabled?).to be true
    end

    it "removes the default toolbar action when disabled" do
      disabled_dashboard = Class.new(SpecCustomerDashboard) do
        def csv_export_enabled?
          false
        end
      end.new

      expect(disabled_dashboard.collection_toolbar_actions(double("view"))).to eq([])
    end
  end

  describe "#csv_attributes" do
    it "defaults to collection attributes" do
      expect(dashboard.csv_attributes).to eq(dashboard.collection_attributes)
    end
  end

  describe "#csv_filename" do
    it "uses the plural resource name" do
      expect(dashboard.csv_filename).to eq("customers.csv")
    end
  end

  describe "#csv_value" do
    it "formats associative display hashes" do
      expect(dashboard.csv_value(:territory, { id: "CA", display: "Canada" }, nil)).to eq("Canada")
    end

    it "formats count and label hashes" do
      expect(dashboard.csv_value(:orders, { count: 2, label: "orders" }, nil)).to eq("2 orders")
    end
  end

  describe "#empty_collection_message" do
    it "returns a default empty state message for the resource" do
      expect(dashboard.empty_collection_message).to eq(
        "No customers match the current view."
      )
    end
  end

  describe "navigation configuration" do
    it "provides default navigation labels, groups, order, and visibility" do
      expect(dashboard.navigation_label).to eq("Customers")
      expect(dashboard.navigation_group).to eq("Resources")
      expect(dashboard.navigation_order).to eq("Customers")
      expect(dashboard.navigation_group_order).to eq("Resources")
      expect(dashboard.show_in_navigation?).to be true
    end

    it "can be customized with dashboard constants" do
      custom_dashboard_class = Class.new(SpecCustomerDashboard)
      custom_dashboard_class.const_set(:NAVIGATION_LABEL, "People")
      custom_dashboard_class.const_set(:NAVIGATION_GROUP, "CRM")
      custom_dashboard_class.const_set(:NAVIGATION_GROUP_ORDER, 10)
      custom_dashboard_class.const_set(:NAVIGATION_ORDER, 20)
      custom_dashboard_class.const_set(:SHOW_IN_NAVIGATION, false)
      custom_dashboard = custom_dashboard_class.new

      expect(custom_dashboard.navigation_label).to eq("People")
      expect(custom_dashboard.navigation_group).to eq("CRM")
      expect(custom_dashboard.navigation_group_order).to eq(10)
      expect(custom_dashboard.navigation_order).to eq(20)
      expect(custom_dashboard.show_in_navigation?).to be false
    end

    it "groups namespaced models by namespace by default" do
      expect(Blog::PostDashboard.new.navigation_group).to eq("Blog")
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
