require "fileutils"
require "open3"
require "stringio"
require "tmpdir"

require "generators/terrazzo/field/field_generator"

RSpec.describe Terrazzo::Generators::FieldGenerator do
  let(:destination_root) { Dir.mktmpdir("terrazzo-field-generator") }
  let(:repo_root) { File.expand_path("../../..", __dir__) }

  after do
    FileUtils.remove_entry(destination_root)
  end

  it "creates app-level barrels and registers the custom field" do
    run_generator(["Rating"])
    create_node_package_link
    write_field_entry

    expect_bundle_to_succeed("field_entry.jsx")

    expect(File).to exist(File.join(destination_root, "app/fields/terrazzo/field/rating.rb"))
    expect_ruby_syntax_to_succeed("app/fields/terrazzo/field/rating.rb")

    fields_barrel = read("app/views/admin/fields/index.js")
    expect(fields_barrel).to include('export * from "terrazzo/fields";')
    expect(fields_barrel).to include('registerRatingFieldType("rating"')
    expect(fields_barrel).to include('export { RatingIndexField, RatingShowField, RatingFormField };')

    ui_barrel = read("app/views/admin/components/ui/index.js")
    expect(ui_barrel).to include('export * from "terrazzo/ui";')
  end

  it "does not duplicate the field registration when rerun" do
    run_generator(["Rating"])
    run_generator(["Rating"])

    fields_barrel = read("app/views/admin/fields/index.js")
    expect(fields_barrel.scan('registerRatingFieldType("rating"').size).to eq(1)
    expect(fields_barrel.scan("./rating/IndexField").size).to eq(1)
  end

  private

  def run_generator(args)
    original_stdout = $stdout
    $stdout = StringIO.new
    described_class.start(args, destination_root: destination_root)
  ensure
    $stdout = original_stdout
  end

  def create_node_package_link
    ensure_npm_package_built
    FileUtils.mkdir_p(File.join(destination_root, "node_modules"))
    FileUtils.ln_s(File.join(repo_root, "npm"), File.join(destination_root, "node_modules", "terrazzo"))
  end

  def ensure_npm_package_built
    dist_files = %w[index fields ui components pages].map do |entry|
      File.join(repo_root, "npm/dist/#{entry}.js")
    end
    return if dist_files.all? { |path| File.exist?(path) }

    stdout, stderr, status = Open3.capture3("npm", "run", "build", chdir: File.join(repo_root, "npm"))
    raise "#{stdout}\n#{stderr}" unless status.success?
  end

  def write_field_entry
    create_file "field_entry.jsx", <<~JS
      import "./app/views/admin/fields/index.js";
      import { FormField as RatingFormField } from "./app/views/admin/fields/rating/FormField.jsx";
      import { Input, Label } from "./app/views/admin/components/ui/index.js";

      console.log(RatingFormField, Input, Label);
    JS
  end

  def expect_bundle_to_succeed(entry)
    stdout, stderr, status = Open3.capture3(
      esbuild_bin,
      entry,
      "--bundle",
      "--format=esm",
      "--outfile=out.js",
      "--loader:.js=jsx",
      "--loader:.jsx=jsx",
      "--jsx=automatic",
      "--external:react",
      "--external:react-dom",
      "--external:react-redux",
      "--external:@reduxjs/toolkit",
      "--external:@thoughtbot/superglue",
      "--external:@radix-ui/*",
      "--external:class-variance-authority",
      "--external:lucide-react",
      "--external:clsx",
      "--external:tailwind-merge",
      chdir: destination_root
    )

    expect(status).to be_success, "#{stdout}\n#{stderr}"
  end

  def expect_ruby_syntax_to_succeed(relative_path)
    stdout, stderr, status = Open3.capture3("ruby", "-c", relative_path, chdir: destination_root)

    expect(status).to be_success, "#{stdout}\n#{stderr}"
  end

  def create_file(relative_path, content)
    path = File.join(destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def read(relative_path)
    File.read(File.join(destination_root, relative_path))
  end

  def esbuild_bin
    File.join(repo_root, "npm/node_modules/.bin/esbuild")
  end
end
