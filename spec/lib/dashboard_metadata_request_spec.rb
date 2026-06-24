require "spec_helper"

RSpec.describe "dashboard field metadata", type: :request do
  before do
    allow_any_instance_of(CustomerDashboard).to receive(:attribute_label).and_call_original
    allow_any_instance_of(CustomerDashboard).to receive(:attribute_hint).and_call_original
    allow_any_instance_of(CustomerDashboard).to receive(:collection_cell_options).and_call_original

    allow_any_instance_of(CustomerDashboard).to receive(:attribute_label)
      .with(:name, :index)
      .and_return("Customer name")
    allow_any_instance_of(CustomerDashboard).to receive(:attribute_label)
      .with(:name, :form)
      .and_return("Full name")
    allow_any_instance_of(CustomerDashboard).to receive(:attribute_label)
      .with(:email, :show)
      .and_return("Primary email")
    allow_any_instance_of(CustomerDashboard).to receive(:attribute_hint)
      .with(:name, :form)
      .and_return("Use the customer's legal name.")
    allow_any_instance_of(CustomerDashboard).to receive(:attribute_hint)
      .with(:email, :show)
      .and_return("Used for receipts.")
    allow_any_instance_of(CustomerDashboard).to receive(:collection_cell_options)
      .with(:name, kind_of(Customer))
      .and_return(class_name: "text-right", tone: "quiet")
  end

  it "serializes index labels and cell options from the dashboard" do
    create_customer(name: "Metadata Test")

    get "/admin/customers", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")
    header = data.dig("table", "headers").find { |item| item.fetch("attribute") == "name" }
    cell = data.dig("table", "rows", 0, "cells").find { |item| item.fetch("attribute") == "name" }

    expect(header.fetch("label")).to eq("Customer name")
    expect(cell.fetch("cellOptions")).to eq({
      "className" => "text-right",
      "meta" => { "tone" => "quiet" },
    })
  end

  it "serializes form labels and hints from the dashboard" do
    get "/admin/customers/new", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")
    field = data.dig("form", "fields").find { |item| item.fetch("attribute") == "name" }
    grouped_field = data.dig("form", "fieldGroups", 0, "fields").find { |item| item.fetch("attribute") == "name" }

    expect(field.fetch("label")).to eq("Full name")
    expect(field.fetch("hint")).to eq("Use the customer's legal name.")
    expect(grouped_field.fetch("label")).to eq("Full name")
    expect(grouped_field.fetch("hint")).to eq("Use the customer's legal name.")
  end

  it "serializes show labels and hints from the dashboard" do
    customer = create_customer(email: "metadata@example.com")

    get "/admin/customers/#{customer.id}", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")
    attribute = data.dig("attributes", "email")

    expect(attribute.fetch("label")).to eq("Primary email")
    expect(attribute.fetch("hint")).to eq("Used for receipts.")
  end

  it "serializes layout actions from the dashboard" do
    customer = create_customer(email: "layout-action@example.com")
    allow_any_instance_of(CustomerDashboard).to receive(:layout_actions)
      .with(:show, anything, resource: kind_of(Customer))
      .and_return([
        {
          label: "Open billing",
          url: "/admin/billing/#{customer.id}",
          variant: "default",
          sg_visit: false,
        },
      ])

    get "/admin/customers/#{customer.id}", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")

    expect(data.fetch("layoutActions")).to eq([
      {
        "label" => "Open billing",
        "url" => "/admin/billing/#{customer.id}",
        "variant" => "default",
        "sg_visit" => false,
      },
    ])
  end

  def json_headers
    { "ACCEPT" => "application/json" }
  end
end
