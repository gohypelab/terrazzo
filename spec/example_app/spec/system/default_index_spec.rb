require "rails_helper"

RSpec.describe "Admin default index", type: :system do
  let!(:beta_series) { create(:series, name: "Beta Series") }
  let!(:alpha_series) { create(:series, name: "Alpha Series") }

  it "renders the packaged index with search, facets, actions, sorting, and CSV export" do
    visit admin_series_index_path

    expect(page).to have_link("Export CSV", href: %r{/admin/series\.csv})
    expect(page).to have_link("Series guide", href: %r{/admin/series#series-guide})
    expect(page).to have_link("Series audit", href: %r{/admin/series\?audit=1})
    expect(find_link("Series guide")["data-sg-visit"]).to be_nil
    expect(find_link("Series audit")["data-sg-visit"]).to be_nil
    expect(page).to have_link("Starts with alpha")
    within(find("table tbody tr", text: "Beta Series")) do
      find("button").click
    end
    expect(page).to have_link("Show")
    expect(page).to have_link("Edit")
    expect(page).to have_button("Destroy")
    send_keys(:escape)

    click_link "Starts with alpha"
    expect(page).to have_current_path(/filter=starts_with_alpha/)
    expect(page).to have_content("Alpha Series")
    expect(page).not_to have_content("Beta Series")

    click_link "All"
    expect(page).to have_content("Alpha Series")
    expect(page).to have_content("Beta Series")

    click_link "Name"
    expect(page).to have_current_path(/order=name/)
    expect(page).to have_current_path(/direction=asc/)
    expect(all("table tbody tr").first).to have_content("Alpha Series")

    fill_in "search", with: "no matching series"
    find("input[name='search']").send_keys(:enter)
    expect(page).to have_current_path(/search=no\+matching\+series/)
    expect(page).to have_content("No series found")
    expect(page).to have_content("No series match the current view.")

    fill_in "search", with: "Beta"
    find("input[name='search']").send_keys(:enter)
    expect(page).to have_content("Beta Series")
    expect(page).not_to have_content("Alpha Series")

    find("table tbody tr", text: "Beta Series").click
    expect(page).to have_current_path(admin_series_path(beta_series))
  end

  it "keeps pagination as clean Superglue page navigation" do
    create_list(:series, 30)

    visit admin_series_index_path

    expect(page).to have_text("Page 1 of 2 - 32 total")

    click_link "Next"

    expect(page).to have_current_path(/_page=2/)
    expect(page).not_to have_current_path(/\.json/)
    expect(page).to have_text("Page 2 of 2 - 32 total")
    expect(page).to have_link("Previous")
  end
end
