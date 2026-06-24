require "spec_helper"

class NavigationWidgetDashboard < Terrazzo::BaseDashboard
  NAVIGATION_LABEL = "Widgets".freeze
  NAVIGATION_GROUP = "Catalog".freeze
  NAVIGATION_GROUP_ORDER = 2
  NAVIGATION_ORDER = 20
end

class HiddenNavigationWidgetDashboard < Terrazzo::BaseDashboard
  SHOW_IN_NAVIGATION = false
end

RSpec.describe Terrazzo::Namespace::Resource do
  def route_for(controller_path)
    double("route", defaults: { controller: controller_path, action: "index" })
  end

  it "uses dashboard navigation hooks when available" do
    resource = described_class.new(route_for("admin/navigation_widgets"))

    expect(resource.navigation_label).to eq("Widgets")
    expect(resource.navigation_group).to eq("Catalog")
    expect(resource.navigation_group_order).to eq(2)
    expect(resource.navigation_order).to eq(20)
    expect(resource).to be_show_in_navigation
  end

  it "falls back to humanized resource names when no dashboard exists" do
    resource = described_class.new(route_for("admin/missing_widgets"))

    expect(resource.navigation_label).to eq("Missing widgets")
    expect(resource.navigation_group).to eq("Resources")
    expect(resource.navigation_order).to eq("Missing widgets")
    expect(resource).to be_show_in_navigation
  end

  it "can be hidden from navigation by its dashboard" do
    resource = described_class.new(route_for("admin/hidden_navigation_widgets"))

    expect(resource).not_to be_show_in_navigation
  end

  it "groups namespaced resources by model namespace by default" do
    resource = described_class.new(route_for("admin/blog/posts"))

    expect(resource.navigation_group).to eq("Blog")
  end
end

RSpec.describe Terrazzo::Namespace do
  let(:router) do
    double("router", routes: [
      double("route", defaults: { controller: "admin/missing_widgets", action: "index" }),
      double("route", defaults: { controller: "admin/navigation_widgets", action: "index" }),
      double("route", defaults: { controller: "admin/hidden_navigation_widgets", action: "index" }),
      double("route", defaults: { controller: "admin/navigation_widgets", action: "show" }),
      double("route", defaults: { controller: "public/widgets", action: "index" }),
    ])
  end

  it "returns visible navigation resources sorted by dashboard hooks" do
    resources = described_class.new(:admin, router).navigation_resources

    expect(resources.map(&:controller_path)).to eq([
      "admin/navigation_widgets",
      "admin/missing_widgets",
    ])
  end
end
