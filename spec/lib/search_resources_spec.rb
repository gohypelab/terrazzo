require "spec_helper"

RSpec.describe Terrazzo::ApplicationController, "search hook" do
  it "applies filters and sorting to the relation from the search override" do
    alice = create_customer(name: "Alice", email: "alice@example.com")
    bob = create_customer(name: "Bob", email: "bob@example.com")
    excluded = create_customer(name: "Excluded", email: "excluded@example.com")
    dashboard =
      Class
        .new(CustomerDashboard) do
          const_set(:COLLECTION_FILTERS, { alice: ->(resources) { resources.where(name: "Alice") } }.freeze)
        end
        .new
    controller =
      Class
        .new(described_class) do
          attr_accessor :search_scope

          private

          def search_resources
            search_scope
          end
        end
        .new
    controller.search_scope = Customer.where(id: [alice.id, bob.id])
    allow(controller).to receive(:dashboard).and_return(dashboard)
    controller.params = { order: "name", direction: "desc" }

    resources, = controller.send(:index_resources_and_order)
    expect(resources.to_a).to eq([bob, alice])
    expect(resources).not_to include(excluded)

    controller.params = { filter: "alice", order: "name" }
    resources, = controller.send(:index_resources_and_order)
    expect(resources.to_a).to eq([alice])
  end
end
