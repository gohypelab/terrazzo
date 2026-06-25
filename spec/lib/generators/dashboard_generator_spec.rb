require "fileutils"
require "open3"
require "spec_helper"
require "stringio"
require "tmpdir"

require "generators/terrazzo/dashboard/dashboard_generator"

RSpec.describe Terrazzo::Generators::DashboardGenerator do
  let(:destination_root) { Dir.mktmpdir("terrazzo-dashboard-generator") }

  after do
    FileUtils.remove_entry(destination_root)
  end

  it "generates user-facing field types for rich text, assets, enums, and associations" do
    run_generator(["Product"])
    run_generator(["Customer"])

    product_dashboard = read("app/dashboards/product_dashboard.rb")
    expect(product_dashboard).to include("banner: Field::RichText,")
    expect(product_dashboard).to include("document: Field::Asset,")
    expect(product_dashboard).to include("product_meta_tag: Field::HasOne,")
    expect(product_dashboard).not_to include("rich_text_banner: Field::HasOne")
    expect(product_dashboard).not_to include("document_attachment")
    expect(product_dashboard).not_to include("document_blob")

    customer_dashboard = read("app/dashboards/customer_dashboard.rb")
    expect(customer_dashboard).to include('kind: Field::Select.with_options(collection: ["standard", "vip"]),')
    expect(customer_dashboard).to include("territory: Field::BelongsTo,")
    expect(customer_dashboard).not_to include("country_code:")
  end

  it "generates conventional nested controllers for namespaced models" do
    run_generator(["Blog::Post"])

    dashboard = read("app/dashboards/blog/post_dashboard.rb")
    expect(dashboard).to include("module Blog\n  class PostDashboard < Terrazzo::BaseDashboard")
    expect(dashboard).not_to include("class Blog::PostDashboard")

    controller = read("app/controllers/admin/blog/posts_controller.rb")
    expect(controller).to include("module Admin\n  module Blog\n    class PostsController < ApplicationController")
    expect(controller).not_to include("class Blog::PostsController")

    expect_ruby_syntax_to_be_valid("app/dashboards/blog/post_dashboard.rb")
    expect_ruby_syntax_to_be_valid("app/controllers/admin/blog/posts_controller.rb")
  end

  it "fails clearly when the model does not exist" do
    generator = described_class.new(["MissingModel"], {}, destination_root: destination_root)

    expect { generator.create_dashboard }
      .to raise_error(Thor::Error, /could not find model 'MissingModel'/)
  end

  private

  def run_generator(args)
    original_stdout = $stdout
    $stdout = StringIO.new
    described_class.start(args, destination_root: destination_root)
  ensure
    $stdout = original_stdout
  end

  def read(relative_path)
    File.read(File.join(destination_root, relative_path))
  end

  def expect_ruby_syntax_to_be_valid(relative_path)
    _stdout, stderr, status = Open3.capture3("ruby", "-c", relative_path, chdir: destination_root)

    expect(status).to be_success, stderr
  end
end
