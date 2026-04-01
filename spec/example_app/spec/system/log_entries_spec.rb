require "rails_helper"

RSpec.describe "Admin Log Entries", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, name: "Alice Johnson", territory: country) }
  let!(:log_entry) { create(:log_entry, action: "create", loggable: customer) }

  describe "index" do
    it "renders the log entries list" do
      visit admin_log_entries_path

      expect(page).to have_content("create")
    end
  end

  describe "show" do
    it "renders the log entry details" do
      visit admin_log_entry_path(log_entry)

      expect(page).to have_content("create")
    end
  end

  describe "edit" do
    it "renders the edit form with the polymorphic association pre-selected" do
      visit edit_admin_log_entry_path(log_entry)

      expect(page).to have_field("Action", with: "create")
      # The polymorphic type dropdown should show "Customer" selected
      expect(page).to have_select("log_entry[loggable_type]", selected: "Customer")
      # The polymorphic id dropdown should show the customer selected
      expect(page).to have_select("log_entry[loggable_id]", selected: "Alice Johnson")
    end

    it "updates the log entry" do
      order = create(:order, customer: customer)

      visit edit_admin_log_entry_path(log_entry)

      fill_in "Action", with: "update"
      select "Order", from: "log_entry[loggable_type]"
      select "Order ##{order.id}", from: "log_entry[loggable_id]"
      click_button "Save"

      expect(page).to have_content("update")
    end
  end
end
