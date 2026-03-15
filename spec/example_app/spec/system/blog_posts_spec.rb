require "rails_helper"

RSpec.describe "Admin Blog Posts", type: :system do
  let!(:blog_post) { create(:blog_post, title: "Hello World", body: "Welcome to the blog.") }

  describe "index" do
    it "renders the blog posts list" do
      visit admin_blog_posts_path

      expect(page).to have_content("Hello World")
    end
  end

  describe "show" do
    it "renders the blog post details" do
      visit admin_blog_post_path(blog_post)

      expect(page).to have_content("Hello World")
      expect(page).to have_content("Welcome to the blog.")
    end
  end

  describe "new" do
    it "renders the new blog post form" do
      visit new_admin_blog_post_path

      expect(page).to have_field("Title")
    end

    it "creates a blog post with valid data" do
      visit new_admin_blog_post_path

      fill_in "Title", with: "New Blog Post"
      fill_in "Body", with: "Post content here"
      click_button "Save"

      expect(page).to have_content("New Blog Post")
    end
  end

  describe "edit" do
    it "renders the edit blog post form" do
      visit edit_admin_blog_post_path(blog_post)

      expect(page).to have_field("Title", with: "Hello World")
    end

    it "updates the blog post" do
      visit edit_admin_blog_post_path(blog_post)

      fill_in "Title", with: "Updated Post"
      click_button "Save"

      expect(page).to have_content("Updated Post")
    end
  end

  describe "destroy" do
    it "deletes the blog post from the show page" do
      visit admin_blog_post_path(blog_post)

      accept_confirm { click_button "Delete" }

      expect(page).to have_current_path(admin_blog_posts_path)
    end
  end
end
