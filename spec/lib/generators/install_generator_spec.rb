require "fileutils"
require "json"
require "open3"
require "stringio"
require "tmpdir"

require "generators/terrazzo/eject/eject_generator"
require "generators/terrazzo/install/install_generator"
require "generators/terrazzo/views/views_generator"

RSpec.describe Terrazzo::Generators::InstallGenerator do
  let(:destination_root) { Dir.mktmpdir("terrazzo-install-generator") }
  let(:repo_root) { File.expand_path("../../..", __dir__) }

  after do
    FileUtils.remove_entry(destination_root)
  end

  it "builds the generated admin JavaScript entrypoint with installed page stubs" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
    })

    run_install_entrypoint_generators
    run_views_generator
    create_node_package_link

    expect(File).to exist(File.join(destination_root, "app/javascript/admin/application.jsx"))
    expect(File).to exist(File.join(destination_root, "app/javascript/admin/page_to_page_mapping.js"))
    expect(File).to exist(File.join(destination_root, "app/javascript/admin/generated_page_mapping.js"))
    expect(File).to exist(File.join(destination_root, "app/javascript/admin/custom_page_mapping.js"))
    expect(File).not_to exist(File.join(destination_root, "app/javascript/admin.js"))
    expect(read("app/views/admin/application/index.jsx")).to include("terrazzo/pages")

    expect_bundle_to_succeed("app/javascript/admin/application.jsx")
  end

  it "builds a Rails esbuild-compatible root entrypoint" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
    })

    run_install_entrypoint_generators(bundler: "esbuild")
    run_views_generator
    create_node_package_link

    expect(read("app/javascript/admin.js")).to eq(%(import "./admin/application.jsx"\n))
    expect_bundle_to_succeed("app/javascript/admin.js")
  end

  it "rejects unsupported JavaScript bundlers" do
    generator = described_class.new([], { bundler: "sprockets" }, destination_root: destination_root)

    expect { generator.validate_bundler }.to raise_error(Thor::Error, /supports Vite or esbuild/)
  end

  it "fails before generation when application model tables are missing" do
    generator = described_class.new([], {}, destination_root: destination_root)
    model = double("Blog::Post", name: "Blog::Post", table_exists?: false)
    allow(generator).to receive(:application_models).and_return([model])

    expect { generator.verify_database_schema }.to raise_error(Thor::Error, /Blog::Post.*db:prepare/m)
  end

  it "continues when application model tables exist" do
    generator = described_class.new([], {}, destination_root: destination_root)
    model = double("Blog::Post", name: "Blog::Post", table_exists?: true)
    allow(generator).to receive(:application_models).and_return([model])

    expect { generator.verify_database_schema }.not_to raise_error
  end

  it "builds the installed admin JavaScript entrypoint after release-gate ejections" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
    })

    run_install_entrypoint_generators
    run_views_generator

    %w[
      pages/index
      pages/edit
      fields/string
      components/Layout
      navigation
    ].each do |target|
      run_eject_generator(target)
    end

    create_node_package_link

    expect(File).to exist(File.join(destination_root, "app/views/admin/application/_collection.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/application/_form.jsx"))
    expect(read("app/views/admin/fields/index.js")).to include('registerStringFieldType("string"')
    expect(read("app/views/admin/components/index.js")).to include("setLayout(Layout);")
    expect(read("app/views/admin/application/_navigation.json.props")).to include("navigation_groups")

    expect_bundle_to_succeed("app/javascript/admin/application.jsx")
  end

  it "sources package and app-owned admin files in the generated stylesheet" do
    run_install_stylesheet_generator

    stylesheet = read("app/assets/stylesheets/admin.css")
    expect(stylesheet).to include('@source "../../views";')
    expect(stylesheet).to include('@source "../../javascript";')
    expect(stylesheet).to include('@source "../../../node_modules/terrazzo/dist";')
  end

  it "prints the package-manager command for missing frontend dependencies" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: {
        "terrazzo" => "^0.6.0",
        "@radix-ui/react-avatar" => "^1.1.0",
      },
    })
    create_file "pnpm-lock.yaml", ""

    output = run_dependency_verifier

    expect(output).to include("Missing frontend dependencies required by Terrazzo")
    expect(output).to include("pnpm add")
    expect(output).to include("@radix-ui/react-select")
    expect(output).to include("@radix-ui/react-label")
    expect(output).to include("tailwindcss")
    expect(output).not_to include("terrazzo @radix-ui/react-avatar")
  end

  it "does not warn when package.json contains the required frontend dependencies" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
    })

    expect(run_dependency_verifier).to eq("")
  end

  it "warns when no Tailwind build pipeline is detected" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
    })
    create_file "pnpm-lock.yaml", ""

    output = run_tailwind_pipeline_verifier

    expect(output).to include("no Tailwind build pipeline was detected")
    expect(output).to include("pnpm add -D @tailwindcss/cli")
    expect(output).to include('"build:admin:css": "tailwindcss -i app/assets/stylesheets/admin.css')
  end

  it "does not warn when package scripts build CSS with Tailwind" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
      scripts: {
        "build:css" => "tailwindcss -i app/assets/stylesheets/admin.css -o app/assets/builds/admin.css --minify",
      },
    })

    expect(run_tailwind_pipeline_verifier).to eq("")
  end

  it "does not warn when Tailwind CLI package tooling is installed" do
    create_file "package.json", JSON.pretty_generate({
      dependencies: described_class::FRONTEND_DEPENDENCIES.to_h { |package_name| [package_name, "*"] },
      devDependencies: {
        "@tailwindcss/cli" => "^4.0.0",
      },
    })

    expect(run_tailwind_pipeline_verifier).to eq("")
  end

  it "does not warn when tailwindcss-rails is installed" do
    create_file "Gemfile.lock", <<~LOCK
      GEM
        specs:
          tailwindcss-rails (4.0.0)
    LOCK

    expect(run_tailwind_pipeline_verifier).to eq("")
  end

  it "keeps the install verifier in sync with package peers and generated CSS dependencies" do
    package_json = JSON.parse(File.read(File.expand_path("../../../npm/package.json", __dir__)))
    expected = ["terrazzo"] + package_json.fetch("peerDependencies").keys + ["tailwindcss"]

    expect(described_class::FRONTEND_DEPENDENCIES.first).to eq("terrazzo")
    expect(described_class::FRONTEND_DEPENDENCIES).to match_array(expected)
  end

  it "lists every package imported by generated app-owned templates" do
    packages = generated_template_package_imports

    expect(packages).to include("terrazzo")
    expect(described_class::FRONTEND_DEPENDENCIES).to include(*packages)
  end

  private

  def run_install_entrypoint_generators(options = {})
    generator = described_class.new([], options, destination_root: destination_root)
    original_stdout = $stdout
    $stdout = StringIO.new
    %i[
      validate_bundler
      create_js_entry_point
      create_esbuild_entry_point
      create_store
      create_page_to_page_mapping
      create_generated_page_mapping
      create_custom_page_mapping
      create_application_visit
      create_flash_slice
    ].each { |method_name| generator.public_send(method_name) }
  ensure
    $stdout = original_stdout
  end

  def run_views_generator
    original_stdout = $stdout
    $stdout = StringIO.new
    Terrazzo::Generators::ViewsGenerator.start([], destination_root: destination_root)
  ensure
    $stdout = original_stdout
  end

  def run_eject_generator(target)
    original_stdout = $stdout
    $stdout = StringIO.new
    Terrazzo::Generators::EjectGenerator.start([target], destination_root: destination_root)
  ensure
    $stdout = original_stdout
  end

  def run_install_stylesheet_generator
    generator = described_class.new([], {}, destination_root: destination_root)
    original_stdout = $stdout
    $stdout = StringIO.new
    generator.create_stylesheet
  ensure
    $stdout = original_stdout
  end

  def run_dependency_verifier
    original_stdout = $stdout
    $stdout = StringIO.new
    described_class.new([], {}, destination_root: destination_root).verify_frontend_dependencies
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def run_tailwind_pipeline_verifier
    original_stdout = $stdout
    $stdout = StringIO.new
    described_class.new([], {}, destination_root: destination_root).verify_tailwind_build_pipeline
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def create_file(relative_path, content)
    path = File.join(destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def read(relative_path)
    File.read(File.join(destination_root, relative_path))
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
      chdir: destination_root
    )

    expect(status).to be_success, "#{stdout}\n#{stderr}"
  end

  def esbuild_bin
    File.join(repo_root, "npm/node_modules/.bin/esbuild")
  end

  def generated_template_package_imports
    template_roots = %w[
      lib/generators/terrazzo/field/templates
      lib/generators/terrazzo/install/templates
      lib/generators/terrazzo/views/templates
    ]

    template_roots.flat_map do |root|
      Dir[File.join(repo_root, root, "**", "*")].filter_map do |path|
        next unless File.file?(path)
        next unless path.match?(/\.(jsx?|erb|tt)$/)

        package_imports_in(File.read(path))
      end
    end.flatten.uniq.sort
  end

  def package_imports_in(source)
    source.scan(/import(?:\s+[^"']+?\s+from\s+|\s*)["']([^"']+)["']/).flatten.filter_map do |specifier|
      next if specifier.start_with?(".", "/")

      package_name_for(specifier)
    end
  end

  def package_name_for(specifier)
    return specifier.split("/").first unless specifier.start_with?("@")

    specifier.split("/").first(2).join("/")
  end
end
