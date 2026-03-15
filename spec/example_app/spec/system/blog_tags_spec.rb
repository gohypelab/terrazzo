require "rails_helper"

RSpec.describe "Admin Blog Tags", type: :system do
  let!(:blog_tag) { create(:blog_tag, name: "announcements") }

  describe "index" do
    it "renders the blog tags list" do
      visit admin_blog_tags_path

      expect(page).to have_content("announcements")
    end
  end

  describe "show" do
    it "renders the blog tag details" do
      visit admin_blog_tag_path(blog_tag)

      expect(page).to have_content("announcements")
    end
  end

  describe "new" do
    it "renders the new blog tag form" do
      visit new_admin_blog_tag_path

      expect(page).to have_field("Name")
    end

    it "creates a blog tag with valid data" do
      visit new_admin_blog_tag_path

      fill_in "Name", with: "tutorials"
      click_button "Save"

      expect(page).to have_content("tutorials")
    end
  end

  describe "edit" do
    it "renders the edit blog tag form" do
      visit edit_admin_blog_tag_path(blog_tag)

      expect(page).to have_field("Name", with: "announcements")
    end

    it "updates the blog tag" do
      visit edit_admin_blog_tag_path(blog_tag)

      fill_in "Name", with: "updated-tag"
      click_button "Save"

      expect(page).to have_content("updated-tag")
    end
  end

  describe "destroy" do
    it "deletes the blog tag from the show page" do
      visit admin_blog_tag_path(blog_tag)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_blog_tags_path)
    end
  end
end
