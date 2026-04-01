require "spec_helper"

RSpec.describe Terrazzo::Field::HasOne do
  describe "#serialize_value" do
    it "returns { id, display } when present" do
      product = Product.create!(
        name: "Widget",
        price: 9.99,
        description: "A widget",
        image_url: "https://example.com/img.png"
      )
      meta_tag = ProductMetaTag.create!(
        product: product,
        meta_title: "Widget SEO",
        meta_description: "Buy a widget"
      )

      field = described_class.new(:product_meta_tag, nil, :show, resource: product)
      result = field.serialize_value(:show)
      expect(result[:id]).to eq(meta_tag.id.to_s)
      expect(result[:display]).to be_present
    end

    it "returns nil when association is nil" do
      product = Product.create!(
        name: "Widget",
        price: 9.99,
        description: "A widget",
        image_url: "https://example.com/img.png"
      )

      field = described_class.new(:product_meta_tag, nil, :show, resource: product)
      expect(field.serialize_value(:show)).to be_nil
    end
  end
end
