require "spec_helper"

RSpec.describe Terrazzo::ResourcePathsHelper do
  include Rails.application.routes.url_helpers
  include described_class

  def namespace
    :admin
  end

  describe "#terrazzo_resource_member_path" do
    it "uses ids instead of model to_param values" do
      product = Product.new(id: 123, slug: "widget-pro")

      expect(terrazzo_resource_member_path(product)).to eq("/admin/products/123")
      expect(terrazzo_resource_member_path(product, action: :edit)).to eq("/admin/products/123/edit")
      expect(terrazzo_resource_member_path(product, action: :destroy)).to eq("/admin/products/123")
    end

    it "routes by terrazzo_resource_param when a host app overrides it" do
      product = Product.new(id: 123, slug: "widget-pro")
      allow(self).to receive(:terrazzo_resource_param) { |resource| resource.to_param }

      expect(terrazzo_resource_member_path(product)).to eq("/admin/products/widget-pro")
      expect(terrazzo_resource_member_path(product, action: :edit)).to eq("/admin/products/widget-pro/edit")
      expect(terrazzo_resource_member_path(product, action: :destroy)).to eq("/admin/products/widget-pro")
    end

    it "builds nested resource paths from the model namespace" do
      post = Blog::Post.new(id: 456)

      expect(terrazzo_resource_member_path(post)).to eq("/admin/blog/posts/456")
      expect(terrazzo_resource_member_path(post, action: :edit)).to eq("/admin/blog/posts/456/edit")
    end
  end

  describe "#terrazzo_resource_collection_path" do
    it "builds collection paths for namespaced models" do
      expect(terrazzo_resource_collection_path(Blog::Post)).to eq("/admin/blog/posts")
    end
  end

  describe "#terrazzo_resource_new_path" do
    it "builds new paths for resource classes" do
      expect(terrazzo_resource_new_path(Product)).to eq("/admin/products/new")
    end
  end
end
