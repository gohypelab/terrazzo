require "rails_helper"

RSpec.describe "Admin Countries", type: :system do
  let!(:country) { Country.find_or_create_by!(code: "US", name: "United States") }

  describe "index" do
    it "renders the countries list" do
      visit admin_countries_path

      expect(page).to have_content("United States")
    end

    it "does not show a New Country button" do
      visit admin_countries_path

      expect(page).not_to have_link("New Country")
      expect(page).not_to have_content("New Country")
    end

    it "does not show edit links" do
      visit admin_countries_path

      expect(page).not_to have_link("Edit")
    end
  end

  describe "show" do
    it "renders the country details" do
      visit admin_country_path(country)

      expect(page).to have_content("United States")
      expect(page).to have_content("US")
    end

    it "does not show an edit button" do
      visit admin_country_path(country)

      expect(page).not_to have_link("Edit")
    end
  end
end
