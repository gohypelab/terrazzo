require "spec_helper"

RSpec.describe Terrazzo::CollectionActionsHelper do
  include Rails.application.routes.url_helpers
  include described_class

  def namespace
    :admin
  end

  describe "#collection_item_actions" do
    before do
      stub_const("Admin", Module.new)
      stub_const("Admin::CountriesController", Class.new(ActionController::Base))
      stub_const("Admin::PaymentsController", Class.new(ActionController::Base))
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
  end
end
