require "rails_helper"

RSpec.describe "Admin Series", type: :system do
  let!(:series) { create(:series, name: "Season 1") }

  describe "index" do
    it "renders the series list" do
      visit admin_series_index_path

      expect(page).to have_content("Season 1")
    end
  end

  describe "show" do
    it "renders the series details" do
      visit admin_series_path(series)

      expect(page).to have_content("Season 1")
    end
  end

  describe "new" do
    it "renders the new series form" do
      visit new_admin_series_path

      expect(page).to have_field("Name")
    end

    it "creates a series with valid data" do
      visit new_admin_series_path

      fill_in "Name", with: "Season 3"
      click_button "Save"

      expect(page).to have_content("Season 3")
    end
  end

  describe "edit" do
    it "renders the edit series form" do
      visit edit_admin_series_path(series)

      expect(page).to have_field("Name", with: "Season 1")
    end

    it "updates the series" do
      visit edit_admin_series_path(series)

      fill_in "Name", with: "Season 1 Updated"
      click_button "Save"

      expect(page).to have_content("Season 1 Updated")
    end
  end

  describe "destroy" do
    it "deletes the series from the show page" do
      visit admin_series_path(series)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_series_index_path)
      expect(page).not_to have_content("Season 1")
    end
  end
end
