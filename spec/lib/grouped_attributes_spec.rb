require "spec_helper"

class GroupedShowDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    email: SuperAdmin::Field::Email,
    created_at: SuperAdmin::Field::DateTime,
    updated_at: SuperAdmin::Field::DateTime,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name email].freeze

  SHOW_PAGE_ATTRIBUTES = {
    "" => %i[id name],
    "Contact" => %i[email],
    "Timestamps" => %i[created_at updated_at],
  }.freeze

  FORM_ATTRIBUTES = {
    "" => %i[name],
    "Contact" => %i[email],
  }.freeze
end

class FlatDashboard < SuperAdmin::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: SuperAdmin::Field::Number,
    name: SuperAdmin::Field::String,
    email: SuperAdmin::Field::Email,
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name email].freeze
  SHOW_PAGE_ATTRIBUTES = %i[id name email].freeze
  FORM_ATTRIBUTES = %i[name email].freeze
end

RSpec.describe "Grouped Attributes" do
  describe SuperAdmin::BaseDashboard do
    describe "#flatten_attributes" do
      let(:dashboard) { GroupedShowDashboard.new }

      it "flattens Hash attributes" do
        attrs = { "" => %i[id name], "Contact" => %i[email] }
        expect(dashboard.flatten_attributes(attrs)).to eq(%i[id name email])
      end

      it "returns Array as-is" do
        attrs = %i[id name email]
        expect(dashboard.flatten_attributes(attrs)).to eq(%i[id name email])
      end
    end

    describe "#permitted_attributes with grouped form" do
      it "flattens Hash FORM_ATTRIBUTES for strong params" do
        dashboard = GroupedShowDashboard.new
        # flatten_attributes is used internally by permitted_attributes
        # Test flatten_attributes directly since permitted_attributes also calls .model
        flat = dashboard.flatten_attributes(dashboard.form_attributes)
        expect(flat).to eq(%i[name email])
      end
    end
  end

  describe SuperAdmin::Page::Show do
    let(:customer) { create_customer(name: "Alice") }

    context "with grouped show attributes" do
      let(:dashboard) { GroupedShowDashboard.new }
      let(:page) { described_class.new(dashboard, customer) }

      it "returns groups from grouped_attributes" do
        groups = page.grouped_attributes
        expect(groups.length).to eq(3)
        expect(groups[0][:name]).to eq("")
        expect(groups[0][:fields].map(&:attribute)).to eq(%i[id name])
        expect(groups[1][:name]).to eq("Contact")
        expect(groups[1][:fields].map(&:attribute)).to eq(%i[email])
        expect(groups[2][:name]).to eq("Timestamps")
        expect(groups[2][:fields].map(&:attribute)).to eq(%i[created_at updated_at])
      end

      it "returns flat list from attributes" do
        attrs = page.attributes
        expect(attrs.map(&:attribute)).to eq(%i[id name email created_at updated_at])
      end
    end

    context "with flat show attributes" do
      let(:dashboard) { FlatDashboard.new }
      let(:page) { described_class.new(dashboard, customer) }

      it "wraps in single unnamed group" do
        groups = page.grouped_attributes
        expect(groups.length).to eq(1)
        expect(groups[0][:name]).to eq("")
        expect(groups[0][:fields].map(&:attribute)).to eq(%i[id name email])
      end

      it "returns flat list from attributes" do
        attrs = page.attributes
        expect(attrs.map(&:attribute)).to eq(%i[id name email])
      end
    end
  end

  describe SuperAdmin::Page::Form do
    let(:customer) { Customer.new }

    context "with grouped form attributes" do
      let(:dashboard) { GroupedShowDashboard.new }
      let(:page) { described_class.new(dashboard, customer) }

      it "returns groups from grouped_attributes" do
        groups = page.grouped_attributes
        expect(groups.length).to eq(2)
        expect(groups[0][:name]).to eq("")
        expect(groups[0][:fields].map(&:attribute)).to eq(%i[name])
        expect(groups[1][:name]).to eq("Contact")
        expect(groups[1][:fields].map(&:attribute)).to eq(%i[email])
      end

      it "returns flat list from attributes" do
        attrs = page.attributes
        expect(attrs.map(&:attribute)).to eq(%i[name email])
      end
    end

    context "with flat form attributes" do
      let(:dashboard) { FlatDashboard.new }
      let(:page) { described_class.new(dashboard, customer) }

      it "wraps in single unnamed group" do
        groups = page.grouped_attributes
        expect(groups.length).to eq(1)
        expect(groups[0][:name]).to eq("")
        expect(groups[0][:fields].map(&:attribute)).to eq(%i[name email])
      end
    end
  end
end
