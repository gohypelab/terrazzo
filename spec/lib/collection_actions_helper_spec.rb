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
  end
end
