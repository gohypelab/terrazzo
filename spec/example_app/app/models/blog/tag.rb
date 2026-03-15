module Blog
  class Tag < ApplicationRecord
    self.table_name = "blog_tags"

    has_and_belongs_to_many :posts,
      class_name: "Blog::Post",
      join_table: "blog_posts_tags"

    validates :name, presence: true
  end
end
