require "spec_helper"

RSpec.describe Terrazzo::ApplicationController, "#terrazzo_page_identifier" do
  let(:controller) { described_class.new }

  before do
    allow(controller).to receive(:controller_path).and_return(controller_path)
    allow(controller).to receive(:action_name).and_return(action_name)
  end

  context "with admin namespace" do
    let(:controller_path) { "admin/customers" }

    context "when action is index" do
      let(:action_name) { "index" }

      it "returns the resource-specific identifier" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/index")
      end
    end

    context "when action is show" do
      let(:action_name) { "show" }

      it "returns the resource-specific identifier" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/show")
      end
    end

    context "when action is new" do
      let(:action_name) { "new" }

      it "returns the resource-specific identifier" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/new")
      end
    end

    context "when action is edit" do
      let(:action_name) { "edit" }

      it "returns the resource-specific identifier" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/edit")
      end
    end

    context "when action is create" do
      let(:action_name) { "create" }

      it "maps to new so failed validations resolve to the correct React component" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/new")
      end
    end

    context "when action is update" do
      let(:action_name) { "update" }

      it "maps to edit so failed validations resolve to the correct React component" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/edit")
      end
    end

    context "when action is destroy" do
      let(:action_name) { "destroy" }

      it "returns the resource-specific identifier" do
        expect(controller.send(:terrazzo_page_identifier)).to eq("admin/customers/destroy")
      end
    end
  end

  context "with a different namespace" do
    let(:controller_path) { "dashboard/orders" }
    let(:action_name) { "index" }

    it "returns the full controller path with action" do
      expect(controller.send(:terrazzo_page_identifier)).to eq("dashboard/orders/index")
    end
  end

  context "with a deeply nested controller path" do
    let(:controller_path) { "admin/blog/posts" }
    let(:action_name) { "show" }

    it "returns the full controller path with action" do
      expect(controller.send(:terrazzo_page_identifier)).to eq("admin/blog/posts/show")
    end
  end
end
