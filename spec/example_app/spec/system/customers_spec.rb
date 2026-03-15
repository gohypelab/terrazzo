require "rails_helper"

RSpec.describe "Admin Customers", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, name: "Alice Johnson", email: "alice@test.com", kind: "vip", territory: country) }

  describe "index" do
    it "renders the customers list" do
      visit admin_customers_path

      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("alice@test.com")
    end
  end

  describe "show" do
    it "renders the customer details" do
      visit admin_customer_path(customer)

      expect(page).to have_content("Alice Johnson")
      expect(page).to have_content("alice@test.com")
      expect(page).to have_content("vip")
    end
  end

  describe "new" do
    it "renders the new customer form" do
      visit new_admin_customer_path

      expect(page).to have_field("Name")
      expect(page).to have_field("Email")
    end

    it "creates a customer with valid data" do
      visit new_admin_customer_path

      fill_in "Name", with: "New Customer"
      fill_in "Email", with: "new@example.com"
      find("label", text: /\AKind/).find(:xpath, "..").find("select").select("Standard")
      find("label", text: /Territory/).find(:xpath, "..").find("select").select("United States")
      click_button "Save"

      expect(page).to have_content("New Customer")
      expect(page).to have_content("new@example.com")
    end
  end

  describe "edit" do
    it "renders the edit customer form" do
      visit edit_admin_customer_path(customer)

      expect(page).to have_field("Name", with: "Alice Johnson")
      expect(page).to have_field("Email", with: "alice@test.com")
    end

    it "updates the customer" do
      visit edit_admin_customer_path(customer)

      fill_in "Name", with: "Alice Updated"
      click_button "Save"

      expect(page).to have_content("Alice Updated")
    end
  end

  describe "destroy" do
    it "deletes the customer from the show page" do
      visit admin_customer_path(customer)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_customers_path)
      expect(page).not_to have_content("Alice Johnson")
    end
  end
end
