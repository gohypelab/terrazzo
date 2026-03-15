module Blog
  class Post < ApplicationRecord
    self.table_name = "blog_posts"

    has_and_belongs_to_many :tags,
      class_name: "Blog::Tag",
      join_table: "blog_posts_tags"

    validates :title, presence: true
    validates :body, presence: true
  end
end
