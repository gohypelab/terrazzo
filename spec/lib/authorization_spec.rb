require "spec_helper"

RSpec.describe "authorization hooks", type: :request do
  it "raises for unauthorized member actions" do
    customer = create_customer
    deny_actions(:show)

    expect do
      get "/admin/customers/#{customer.id}", headers: json_headers
    end.to raise_error(Terrazzo::NotAuthorizedError)
  end

  it "raises for unauthorized create before requiring form params" do
    deny_actions(:create)

    expect do
      post "/admin/customers", headers: json_headers
    end.to raise_error(Terrazzo::NotAuthorizedError)
  end

  it "hides unauthorized collection actions in index props" do
    create_customer
    deny_actions(:new, :edit, :destroy)

    get "/admin/customers", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")
    row = data.dig("table", "rows").first

    expect(data.fetch("newResourcePath")).to be_nil
    expect(row.fetch("collectionItemActions").map { |action| action.fetch("label") }).to eq(["Show"])
  end

  it "hides unauthorized show page actions in props" do
    customer = create_customer
    deny_actions(:edit, :destroy)

    get "/admin/customers/#{customer.id}", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")

    expect(data.fetch("editPath")).to be_nil
    expect(data.fetch("deletePath")).to be_nil
  end

  it "hides unauthorized association links in index cell props" do
    create_customer
    deny_country_show

    get "/admin/customers", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")
    cell = data.dig("table", "rows", 0, "cells").find { |item| item.fetch("attribute") == "territory" }

    expect(cell.fetch("showPath")).to be_nil
  end

  it "hides unauthorized association links in show props" do
    customer = create_customer
    deny_country_show

    get "/admin/customers/#{customer.id}", headers: json_headers

    expect(response).to have_http_status(:ok)
    data = JSON.parse(response.body).fetch("data")

    expect(data.dig("attributes", "territory", "showPath")).to be_nil
  end

  private

  def deny_actions(*denied_actions)
    denied = denied_actions.map(&:to_sym)
    allow_any_instance_of(Admin::ApplicationController).to receive(:authorized_action?) do |_controller, _resource, action|
      !denied.include?(action.to_sym)
    end
  end

  def deny_country_show
    allow_any_instance_of(Admin::ApplicationController).to receive(:authorized_action?) do |_controller, resource, action|
      !(resource.is_a?(Country) && action.to_sym == :show)
    end
  end

  def json_headers
    { "ACCEPT" => "application/json" }
  end
end
