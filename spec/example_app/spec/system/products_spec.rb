require "rails_helper"

RSpec.describe "Admin Products", type: :system do
  let!(:product) { create(:product, name: "Widget Pro", price: 29.99, description: "A professional widget", image_url: "https://picsum.photos/200") }

  describe "index" do
    it "renders the products list" do
      visit admin_products_path

      expect(page).to have_content("Widget Pro")
      expect(page).to have_content("29.99")
    end
  end

  describe "show" do
    it "renders the product details" do
      visit admin_product_path(product)

      expect(page).to have_content("Widget Pro")
      expect(page).to have_content("29.99")
      expect(page).to have_content("A professional widget")
    end
  end

  describe "new" do
    it "renders the new product form" do
      visit new_admin_product_path

      expect(page).to have_field("Name")
      expect(page).to have_field("Price")
    end

    it "creates a product with valid data" do
      meta_tag = create(:product_meta_tag, product: product)
      visit new_admin_product_path

      fill_in "Name", with: "New Widget"
      fill_in "Price", with: "49.99"
      fill_in "Description", with: "A brand new widget"
      fill_in "Image url", with: "https://picsum.photos/300"
      find("label", text: /Product meta tag/).find(:xpath, "..").find("select").select("ProductMetaTag ##{meta_tag.id}")
      click_button "Save"

      expect(page).to have_content("New Widget")
    end
  end

  describe "file upload" do
    it "uploads a document and displays the filename" do
      visit edit_admin_product_path(product)

      attach_file "Document", Rails.root.join("spec/fixtures/files/test_document.txt")
      click_button "Save"

      expect(page).to have_content("test_document.txt")
    end
  end

  describe "edit" do
    it "renders the edit product form" do
      visit edit_admin_product_path(product)

      expect(page).to have_field("Name", with: "Widget Pro")
    end

    it "updates the product" do
      visit edit_admin_product_path(product)

      fill_in "Name", with: "Widget Pro Updated"
      click_button "Save"

      expect(page).to have_content("Widget Pro Updated")
    end
  end

  describe "destroy" do
    it "deletes the product from the show page" do
      visit admin_product_path(product)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_products_path)
      expect(page).not_to have_content("Widget Pro")
    end
  end
end
