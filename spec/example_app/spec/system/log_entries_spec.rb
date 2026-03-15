require "rails_helper"

RSpec.describe "Admin Log Entries", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }
  let!(:customer) { create(:customer, territory: country) }
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
end
