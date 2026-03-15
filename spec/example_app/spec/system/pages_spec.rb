require "rails_helper"

RSpec.describe "Admin Pages", type: :system do
  let!(:product) { create(:product) }
  let!(:page_record) { create(:page, title: "Product Details", body: "Learn more", product: product) }

  describe "index" do
    it "renders the pages list" do
      visit admin_pages_path

      expect(page).to have_content("Product Details")
    end
  end

  describe "show" do
    it "renders the page details" do
      visit admin_page_path(page_record)

      expect(page).to have_content("Product Details")
      expect(page).to have_content("Learn more")
    end
  end

  describe "new" do
    it "renders the new page form" do
      visit new_admin_page_path

      expect(page).to have_field("Title")
    end

    it "creates a page with valid data" do
      visit new_admin_page_path

      fill_in "Title", with: "New Page"
      fill_in "Body", with: "New page content"
      click_button "Save"

      expect(page).to have_content("New Page")
    end
  end

  describe "edit" do
    it "renders the edit page form" do
      visit edit_admin_page_path(page_record)

      expect(page).to have_field("Title", with: "Product Details")
    end

    it "updates the page" do
      visit edit_admin_page_path(page_record)

      fill_in "Title", with: "Updated Title"
      click_button "Save"

      expect(page).to have_content("Updated Title")
    end
  end

  describe "destroy" do
    it "deletes the page from the show page" do
      visit admin_page_path(page_record)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_pages_path)
    end
  end
end
