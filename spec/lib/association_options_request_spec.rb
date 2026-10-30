require "spec_helper"

RSpec.describe "association option loading", type: :request do
  let(:headers) { { "ACCEPT" => "application/json" } }

  it "loads only the selected record in an edit form and serializes it once" do
    selected = create_customer(name: "Selected")
    order = create_order(customer: selected)
    30.times { |i| create_customer(name: "Candidate #{i}") }
    counts = []
    subscriber = ->(*args) { counts << args.last[:record_count] if args.last[:class_name] == "Customer" }
    ActiveSupport::Notifications.subscribed(subscriber, "instantiation.active_record") do
      get "/admin/orders/#{order.id}/edit", headers: headers
    end
    form = response.parsed_body.fetch("data").fetch("form")
    field = form.fetch("fields").find { |item| item["attribute"] == "customer" }
    expect(field.dig("options", "resourceOptions")).to eq([["Selected", selected.id.to_s]])
    expect(counts.sum).to eq(1)
    expect(form.fetch("fieldGroups").first).not_to have_key("fields")
    expect(field.dig("options", "optionsUrl")).to include("association=customer")
  end

  it "loads no candidate records for an empty new form" do
    create_customer(name: "Unselected")
    counts = []
    subscriber = ->(*args) { counts << args.last[:record_count] if args.last[:class_name] == "Customer" }
    ActiveSupport::Notifications.subscribed(subscriber, "instantiation.active_record") do
      get "/admin/orders/new", headers: headers
    end
    field = response.parsed_body.dig("data", "form", "fields").find { |item| item["attribute"] == "customer" }
    expect(field.dig("options", "resourceOptions")).to eq([])
    expect(counts.sum).to eq(0)
  end

  it "loads only the first ten matches and finds records beyond that limit through search" do
    candidates = 31.times.map { |i| create_customer(name: "Candidate #{i}") }
    counts = []
    subscriber = ->(*args) { counts << args.last[:record_count] if args.last[:class_name] == "Customer" }
    ActiveSupport::Notifications.subscribed(subscriber, "instantiation.active_record") do
      get "/admin/orders/new", params: { association: "customer", search: "Candidate", per_page: 10_000 }, headers: headers
    end
    first = response.parsed_body
    expect(first.fetch("resourceOptions").map(&:last)).to eq(candidates.first(10).map { |record| record.id.to_s })
    expect(first.keys).to eq(["resourceOptions"])
    expect(counts.sum).to eq(10)
    expect(response.headers["Cache-Control"]).to include("no-store")
    get "/admin/orders/new", params: { association: "customer", search: "Candidate 30" }, headers: headers
    second = response.parsed_body
    expect(second.fetch("resourceOptions")).to eq([[candidates.last.name, candidates.last.id.to_s]])
  end

  it "searches in SQL, escapes wildcards, and supports empty results" do
    matching = create_customer(name: "100% Match")
    create_customer(name: "100 percent")
    get "/admin/orders/new", params: { association: "customer", search: "100%" }, headers: headers
    expect(response.parsed_body.fetch("resourceOptions")).to eq([[matching.name, matching.id.to_s]])
    get "/admin/orders/new", params: { association: "customer", search: "missing" }, headers: headers
    expect(response.parsed_body.fetch("resourceOptions")).to eq([])
  end

  it "rejects fields outside the form and fields without option queries" do
    %w[created_at address_city unknown].each do |attribute|
      get "/admin/orders/new", params: { association: attribute }, headers: headers
      expect(response).to have_http_status(:not_found)
    end
  end

  it "checks parent authorization before loading options" do
    allow_any_instance_of(Admin::OrdersController).to receive(:authorized_action?).and_return(false)
    expect do
      get "/admin/orders/new", params: { association: "customer" }, headers: headers
    end.to raise_error(Terrazzo::NotAuthorizedError)
  end

  it "preserves a non-id association key" do
    country = create_country(code: "CA", name: "Canada")
    customer = create_customer(country: country)
    field = Terrazzo::Field::BelongsTo.new(:territory, nil, :form, resource: customer)
    expect(field.serializable_options(:form)[:resourceOptions]).to eq([["Canada", "CA"]])
    expect(field.association_options(search: "Canada")[:resourceOptions]).to eq([["Canada", "CA"]])
  end

  it "returns only selected has-many records and bounds candidate loading" do
    selected = create_customer(name: "Owner")
    order = create_order(customer: selected)
    other = create_customer(name: "Other")
    30.times { create_order(customer: other) }
    field = Terrazzo::Field::HasMany.new(:orders, nil, :form, resource: selected)
    expect(field.serializable_options(:form)[:resourceOptions].map(&:last)).to eq([order.id.to_s])
    counts = []
    subscriber = ->(*args) { counts << args.last[:record_count] if args.last[:class_name] == "Order" }
    ActiveSupport::Notifications.subscribed(subscriber, "instantiation.active_record") do
      expect(field.association_options(search: "")[:resourceOptions].length).to eq(10)
    end
    expect(counts.sum).to eq(10)
  end

  it "retains a submitted selection after validation fails" do
    selected = create_customer(name: "Submitted")
    post "/admin/orders", params: { order: { customer_id: selected.id } }, headers: headers
    expect(response).to have_http_status(:unprocessable_entity)
    field = response.parsed_body.dig("data", "form", "fields").find { |item| item["attribute"] == "customer" }
    expect(field.fetch("value")).to eq(selected.id.to_s)
    expect(field.dig("options", "resourceOptions")).to eq([[selected.name, selected.id.to_s]])
  end

  it "uses the configured candidate scope and preserves selected values outside it" do
    selected = create_customer(name: "Selected")
    candidate = create_customer(name: "Candidate")
    field = Terrazzo::Field::BelongsTo.new(:customer, nil, :form,
      resource: Order.new(customer: selected), options: { scope: ->(model) { model.where(id: candidate.id) } })
    expect(field.serializable_options(:form)[:resourceOptions]).to eq([[selected.name, selected.id.to_s]])
    expect(field.association_options(search: "")[:resourceOptions]).to eq([[candidate.name, candidate.id.to_s]])
  end
end
