require "rails_helper"

RSpec.describe "Admin Navigation", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, territory: country) }

  describe "root redirect" do
    it "redirects / to /admin" do
      visit "/"

      expect(page).to have_current_path(%r{/admin})
    end
  end

  describe "sidebar navigation" do
    it "renders the sidebar with resource links" do
      visit admin_root_path

      expect(page).to have_link("Customers")
      expect(page).to have_link("Orders")
      expect(page).to have_link("Products")
    end

    it "renders the sidebar on the show page" do
      visit admin_customer_path(customer)

      expect(page).to have_link("Customers")
      expect(page).to have_link("Orders")
      expect(page).to have_link("Products")
    end

    it "renders the sidebar on the edit page" do
      visit edit_admin_customer_path(customer)

      expect(page).to have_link("Customers")
      expect(page).to have_link("Orders")
      expect(page).to have_link("Products")
    end

    it "renders the sidebar on the new page" do
      visit new_admin_customer_path

      expect(page).to have_link("Customers")
      expect(page).to have_link("Orders")
      expect(page).to have_link("Products")
    end

    it "navigates between resources via sidebar" do
      visit admin_customers_path
      click_link "Products"

      expect(page).to have_current_path(admin_products_path)
    end

    it "renders grouped navigation from the overridden partial" do
      visit admin_customers_path

      expect(page).to have_text("Resources")
      expect(page).to have_text("Blog")
      expect(page).to have_link("Posts")
      expect(page).to have_link("Tags")
      expect(page).to have_link("Customers")
    end
  end

  describe "search" do
    it "renders the search bar on index pages" do
      visit admin_customers_path

      expect(page).to have_css("input[type='search'], input[placeholder*='Search'], input[name*='search']")
    end
  end

  describe "pagination" do
    before do
      20.times { create(:customer, territory: country) }
    end

    it "renders pagination when there are many records" do
      visit admin_customers_path

      expect(page).to have_css("[data-testid='pagination'], nav[aria-label*='pagination'], .pagination, a[href*='page']")
    end
  end
end
