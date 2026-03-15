require "rails_helper"

RSpec.describe "Admin Product Meta Tags", type: :system do
  let!(:product) { create(:product) }
  let!(:product_meta_tag) { create(:product_meta_tag, product: product, meta_title: "Buy Widget", meta_description: "Best widget online") }

  describe "index" do
    it "renders the product meta tags list" do
      visit admin_product_meta_tags_path

      expect(page).to have_content("Buy Widget")
    end
  end

  describe "show" do
    it "renders the product meta tag details" do
      visit admin_product_meta_tag_path(product_meta_tag)

      expect(page).to have_content("Buy Widget")
      expect(page).to have_content("Best widget online")
    end
  end

  describe "new" do
    it "renders the new product meta tag form" do
      visit new_admin_product_meta_tag_path

      expect(page).to have_field("Meta title")
    end

    it "creates a product meta tag with valid data" do
      other_product = create(:product, name: "Unlinked Product")
      visit new_admin_product_meta_tag_path

      select "Unlinked Product", from: "Product"
      fill_in "Meta title", with: "New Meta Title"
      fill_in "Meta description", with: "New meta description"
      click_button "Save"

      expect(page).to have_content("New Meta Title")
    end
  end

  describe "edit" do
    it "renders the edit product meta tag form" do
      visit edit_admin_product_meta_tag_path(product_meta_tag)

      expect(page).to have_field("Meta title", with: "Buy Widget")
    end

    it "updates the product meta tag" do
      visit edit_admin_product_meta_tag_path(product_meta_tag)

      fill_in "Meta title", with: "Updated Meta"
      click_button "Save"

      expect(page).to have_content("Updated Meta")
    end
  end

  describe "destroy" do
    it "deletes the product meta tag from the show page" do
      visit admin_product_meta_tag_path(product_meta_tag)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_product_meta_tags_path)
    end
  end
end
