require "spec_helper"

RSpec.describe Terrazzo::CollectionActionsHelper do
  include Rails.application.routes.url_helpers
  include Terrazzo::ResourcePathsHelper
  include described_class

  def namespace
    :admin
  end

  describe "#collection_item_actions" do
    before do
      stub_const("Admin", Module.new)
      stub_const("Admin::CountriesController", Class.new(ActionController::Base))
      stub_const("Admin::PaymentsController", Class.new(ActionController::Base))
      stub_const("Admin::ProductsController", Class.new(ActionController::Base))
    end

    it "omits destroy when the destroy route is unavailable" do
      payment = Payment.new(id: 123)
      allow(payment).to receive(:persisted?).and_return(true)

      actions = collection_item_actions(payment)

      expect(actions.map { |action| action[:label] }).to eq(["Show", "Edit"])
    end

    it "includes destroy when the destroy route is available" do
      country = Country.new(id: 123, code: "US", name: "United States")
      allow(country).to receive(:persisted?).and_return(true)

      actions = collection_item_actions(country)

      expect(actions.map { |action| action[:label] }).to eq(["Show", "Destroy"])
      expect(actions.find { |action| action[:label] == "Destroy" }).to include(method: "delete")
    end

    it "uses id-based URLs when the model overrides to_param" do
      product = Product.new(id: 123, slug: "widget-pro")

      actions = collection_item_actions(product)

      expect(actions).to include(label: "Show", url: "/admin/products/123")
      expect(actions).to include(label: "Edit", url: "/admin/products/123/edit")
      expect(actions.find { |action| action[:label] == "Destroy" }).to include(url: "/admin/products/123")
    end

    it "omits default actions denied by authorized_action?" do
      country = Country.new(id: 123, code: "US", name: "United States")

      allow(self).to receive(:authorized_action?) do |_resource, action|
        action.to_sym != :destroy
      end

      actions = collection_item_actions(country)

      expect(actions.map { |action| action[:label] }).to eq(["Show"])
    end

    it "lets dashboard row action overrides extend the defaults with super" do
      stub_const("CountryDashboard", Class.new(Terrazzo::BaseDashboard) do
        def collection_item_actions(resource, view)
          super + [
            {
              label: "Audit",
              url: "#{view.collection_action_path(resource, :show)}/audit",
            },
          ]
        end
      end)

      country = Country.new(id: 123, code: "US", name: "United States")
      allow(country).to receive(:persisted?).and_return(true)

      actions = collection_item_actions(country)

      expect(actions.map { |action| action[:label] }).to eq(["Show", "Destroy", "Audit"])
      expect(actions.last).to include(url: "/admin/countries/123/audit")
    end
  end

  describe "#has_many_pagination_paths" do
    it "replaces stale page params for the paginated field only" do
      field = double("field", attribute: :orders, current_page: 2, total_pages: 4)
      customer = Customer.new(id: 123)
      allow(customer).to receive(:persisted?).and_return(true)
      allow(self).to receive(:controller_path).and_return("admin/customers")
      allow(self).to receive(:request).and_return(
        double(
          "request",
          query_parameters: {
            "orders_page" => "9",
            "hm_orders_page" => "2",
            "hm_log_entries_page" => "3",
            "search" => "alice",
          }
        )
      )

      paths = has_many_pagination_paths(field, customer)
      next_query = Rack::Utils.parse_nested_query(URI.parse(paths.fetch(:nextPagePath)).query)
      prev_query = Rack::Utils.parse_nested_query(URI.parse(paths.fetch(:prevPagePath)).query)

      expect(next_query).to include(
        "hm_orders_page" => "3",
        "hm_log_entries_page" => "3",
        "search" => "alice",
        "props_at" => "data.attributes.orders"
      )
      expect(next_query).not_to have_key("orders_page")
      expect(prev_query).to include("hm_orders_page" => "1")
    end
  end
end
