require "spec_helper"

RSpec.describe "admin index pagination", type: :request do
  it "honors valid per-page values in the serialized pagination payload" do
    create_customers(3)

    get "/admin/customers", params: { per_page: 2 }, headers: json_headers

    pagination = response_data.fetch("pagination")
    expect(pagination.fetch("perPage")).to eq(2)
    expect(response_data.dig("table", "rows").length).to eq(2)
    expect(pagination.fetch("nextPagePath")).to include("per_page=2")
  end

  it "falls back to the default per-page value for invalid values" do
    create_customers(26)

    get "/admin/customers", params: { per_page: "invalid" }, headers: json_headers

    pagination = response_data.fetch("pagination")
    expect(pagination.fetch("perPage")).to eq(25)
    expect(response_data.dig("table", "rows").length).to eq(25)
    expect(pagination.fetch("nextPagePath")).to include("per_page=25")
  end

  it "clamps oversized per-page values before querying and building links" do
    create_customers(101)

    get "/admin/customers", params: { per_page: 10_000 }, headers: json_headers

    pagination = response_data.fetch("pagination")
    expect(pagination.fetch("perPage")).to eq(100)
    expect(response_data.dig("table", "rows").length).to eq(100)
    expect(pagination.fetch("nextPagePath")).to include("per_page=100")
  end

  it "lets admin controllers override the default and maximum per-page limits" do
    allow_any_instance_of(Admin::CustomersController).to receive(:default_per_page).and_return(3)
    allow_any_instance_of(Admin::CustomersController).to receive(:max_per_page).and_return(4)
    create_customers(5)

    get "/admin/customers", params: { per_page: "invalid" }, headers: json_headers

    pagination = response_data.fetch("pagination")
    expect(pagination.fetch("perPage")).to eq(3)
    expect(pagination.fetch("nextPagePath")).to include("per_page=3")

    get "/admin/customers", params: { per_page: 20 }, headers: json_headers

    pagination = response_data.fetch("pagination")
    expect(pagination.fetch("perPage")).to eq(4)
    expect(pagination.fetch("nextPagePath")).to include("per_page=4")
  end

  private

  def create_customers(count)
    count.times do |i|
      create_customer(
        name: "Pagination Customer #{i}",
        email: "pagination-customer-#{i}@example.com"
      )
    end
  end

  def response_data
    JSON.parse(response.body).fetch("data")
  end

  def json_headers
    { "ACCEPT" => "application/json" }
  end
end
