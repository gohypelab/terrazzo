require "fileutils"
require "open3"
require "stringio"
require "tmpdir"

require "generators/terrazzo/eject/eject_generator"
require "generators/terrazzo/field/field_generator"
require "generators/terrazzo/views/edit_generator"
require "generators/terrazzo/views/field_generator"
require "generators/terrazzo/views/index_generator"
require "generators/terrazzo/views/layout_generator"
require "generators/terrazzo/views/navigation_generator"
require "generators/terrazzo/views/new_generator"
require "generators/terrazzo/views/show_generator"
require "generators/terrazzo/views/views_generator"

RSpec.describe Terrazzo::Generators::EjectGenerator do
  let(:destination_root) { Dir.mktmpdir("terrazzo-generator-smoke") }
  let(:repo_root) { File.expand_path("../../..", __dir__) }

  after do
    FileUtils.remove_entry(destination_root)
  end

  it "builds JavaScript after the release-gate ejections" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    %w[
      pages/index
      pages/edit
      fields/string
      fields/asset
      components/Layout
      components/ResourceTable
      ui/button
      navigation
    ].each do |target|
      run_generator(described_class, [target])
    end
    run_generator(Terrazzo::Generators::FieldGenerator, ["Rating"])

    create_node_package_link
    write_smoke_entry

    expect_bundle_to_succeed("entry.jsx")

    expect(File).to exist(File.join(destination_root, "app/views/admin/application/_collection.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/application/_form.jsx"))

    expect(read("app/views/admin/fields/index.js")).to include('export * from "terrazzo/fields";')
    expect(read("app/views/admin/fields/index.js")).to include('registerStringFieldType("string"')
    expect(read("app/views/admin/fields/index.js")).to include('registerAssetFieldType("asset"')
    expect(read("app/views/admin/fields/index.js")).to include('registerRatingFieldType("rating"')
    expect(read("app/views/admin/components/index.js")).to include('export * from "terrazzo/components";')
    expect(read("app/views/admin/components/index.js")).to include("setLayout(Layout);")
    expect(read("app/views/admin/components/index.js")).to include('registerResourceTableComponent("ResourceTable", ResourceTable);')
    expect(read("app/views/admin/components/ui/index.js")).to include('export { Button, buttonVariants } from "./button";')
    expect(read("app/views/admin/application/_navigation.json.props")).to include("navigation_resources")
    expect(read("app/views/admin/application/_navigation.json.props")).to include("navigation_groups")
    expect(read("app/views/admin/application/_navigation.json.props")).to include("json.items")
  end

  it "replaces installed page stubs without conflict prompts" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    output = %w[pages/index pages/show pages/new pages/edit].map do |target|
      run_generator(described_class, [target])
    end.join

    expect(output).not_to include("conflict")
    expect(output).not_to include("Overwrite")
    expect(read("app/views/admin/application/index.jsx")).to include("export default function AdminIndex")
    expect(read("app/views/admin/application/show.jsx")).to include("export default function AdminShow")
    expect(read("app/views/admin/application/new.jsx")).to include("export default function AdminNew")
    expect(read("app/views/admin/application/edit.jsx")).to include("export default function AdminEdit")
  end

  it "replaces the installed navigation partial without a conflict prompt" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    output = run_generator(described_class, ["navigation"])

    expect(output).not_to include("conflict")
    expect(output).not_to include("Overwrite")
    expect(read("app/views/admin/application/_navigation.json.props")).to include("nav_resource.navigation_label")
  end

  it "fails loudly for unsupported ejection targets" do
    {
      "widgets/button" => /Unknown ejection target 'widgets\/button'/,
      "fields/nope" => /Unknown field type 'nope'/,
      "components/Nope" => /Unknown component 'Nope'/,
      "ui/nope" => /Unknown UI component 'nope'/,
      "pages/nope" => /Unknown page template 'nope'/,
      "navigation/sidebar" => /Unknown ejection target 'navigation\/sidebar'/,
    }.each do |target, message|
      expect { eject_directly(target) }.to raise_error(Thor::Error, message)
    end
  end

  it "builds JavaScript after resource-specific view generation" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])
    create_file "app/views/admin/orders/edit.jsx", "export default function PlaceholderOrderEdit() { return null; }\n"
    create_file "app/views/admin/payments/new.jsx", "export default function PlaceholderPaymentNew() { return null; }\n"

    run_generator(Terrazzo::Generators::Views::IndexGenerator, ["Order"])
    run_generator(Terrazzo::Generators::Views::ShowGenerator, ["Order"])
    run_generator(Terrazzo::Generators::Views::NewGenerator, ["Order"])
    run_generator(Terrazzo::Generators::Views::EditGenerator, ["Payment"])

    create_node_package_link
    write_resource_view_entry

    expect_bundle_to_succeed("resource_entry.jsx")
    expect(File).to exist(File.join(destination_root, "app/views/admin/orders/_collection.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/orders/_form.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/payments/_form.jsx"))

    manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(manifest).to include('import OrderIndex from "../../views/admin/orders/index";')
    expect(manifest).to include('import OrderShow from "../../views/admin/orders/show";')
    expect(manifest).to include('import OrderNew from "../../views/admin/orders/new";')
    expect(manifest).to include('import PaymentEdit from "../../views/admin/payments/edit";')
    expect(manifest).to include("'admin/orders/index': OrderIndex,")
    expect(manifest).to include("'admin/orders/show': OrderShow,")
    expect(manifest).to include("'admin/orders/new': OrderNew,")
    expect(manifest).to include("'admin/payments/edit': PaymentEdit,")
  end

  it "builds JavaScript after standalone resource-specific view generation" do
    run_generator(Terrazzo::Generators::Views::IndexGenerator, ["Order"])
    run_generator(Terrazzo::Generators::Views::ShowGenerator, ["Order"])
    run_generator(Terrazzo::Generators::Views::NewGenerator, ["Invoice", "--with-counterpart"])
    run_generator(Terrazzo::Generators::Views::EditGenerator, ["Payment", "--no-with-counterpart"])

    create_node_package_link
    write_standalone_resource_view_entry

    expect_bundle_to_succeed("standalone_resource_entry.jsx")
    expect(read("app/views/admin/fields/index.js")).to include('export * from "terrazzo/fields";')
    expect(read("app/views/admin/components/index.js")).to include('export * from "terrazzo/components";')
    expect(read("app/views/admin/components/ui/index.js")).to include('export * from "terrazzo/ui";')

    manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(manifest).to include("'admin/orders/index': OrderIndex,")
    expect(manifest).to include("'admin/orders/show': OrderShow,")
    expect(manifest).to include("'admin/invoices/new': InvoiceNew,")
    expect(manifest).to include("'admin/invoices/edit': InvoiceEdit,")
    expect(manifest).to include("'admin/payments/edit': PaymentEdit,")
  end

  it "builds JavaScript after ejecting every supported component" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    component_names.each do |name|
      run_generator(described_class, ["components/#{name}"])
    end
    run_generator(described_class, ["components/ResourceTable"])

    create_node_package_link
    write_all_components_entry

    expect_bundle_to_succeed("all_components_entry.jsx")

    components_barrel = read("app/views/admin/components/index.js")
    expected_component_exports.each_value do |export_name|
      expect(components_barrel).to include(export_name)
    end
    expect(components_barrel.scan('registerResourceTableComponent("ResourceTable", ResourceTable);').size).to eq(1)
  end

  it "builds JavaScript after ejecting each supported component on its own" do
    component_names.each do |name|
      reset_destination_root
      run_generator(Terrazzo::Generators::ViewsGenerator, [])
      run_generator(described_class, ["components/#{name}"])

      create_node_package_link
      write_component_entry

      expect_bundle_to_succeed("component_entry.jsx")
      expect(File).to exist(File.join(destination_root, "app/views/admin/components/#{name}.jsx"))

      components_barrel = read("app/views/admin/components/index.js")
      export_name = expected_component_exports.fetch(name)
      if name == "Layout"
        expect(components_barrel).to include("setLayout(Layout);")
      else
        expect(components_barrel).to include(%(register#{export_name}Component("#{export_name}", #{export_name});))
      end

      component_dependencies_for(name).each do |dependency|
        expect(File).to exist(File.join(destination_root, "app/views/admin/components/#{dependency}.jsx"))
      end
    end
  end

  it "builds JavaScript after ejecting each supported UI primitive" do
    ui_component_names.each do |name|
      reset_destination_root
      run_generator(Terrazzo::Generators::ViewsGenerator, [])
      run_generator(described_class, ["ui/#{name}"])

      create_node_package_link
      write_ui_entry

      expect_bundle_to_succeed("ui_entry.jsx")
      expect(File).to exist(File.join(destination_root, "app/views/admin/components/ui/#{name}.jsx"))
      expect(read("app/views/admin/components/ui/index.js"))
        .to include(%(export { #{ui_exports_for(name)} } from "./#{name}";))

      ui_dependencies_for(name).each do |dependency|
        expect(File).to exist(File.join(destination_root, "app/views/admin/components/ui/#{dependency}.jsx"))
      end
    end
  end

  it "builds JavaScript after ejecting each supported field type" do
    field_names.each do |name|
      reset_destination_root
      run_generator(Terrazzo::Generators::ViewsGenerator, [])
      run_generator(described_class, ["fields/#{name}"])

      create_node_package_link
      write_fields_entry

      expect_bundle_to_succeed("fields_entry.jsx")
      expect(File).to exist(File.join(destination_root, "app/views/admin/fields/#{name}/IndexField.jsx"))
      expect(File).to exist(File.join(destination_root, "app/views/admin/fields/#{name}/ShowField.jsx"))
      expect(File).to exist(File.join(destination_root, "app/views/admin/fields/#{name}/FormField.jsx"))

      if field_uses_shared_text_input?(name)
        expect(File).to exist(File.join(destination_root, "app/views/admin/fields/shared/TextInputFormField.jsx"))
      end
    end
  end

  it "builds JavaScript after standalone ejection of each supported field type" do
    field_names.each do |name|
      reset_destination_root
      run_generator(described_class, ["fields/#{name}"])

      create_node_package_link
      write_fields_entry

      expect_bundle_to_succeed("fields_entry.jsx")
      expect(read("app/views/admin/fields/index.js")).to include('export * from "terrazzo/fields";')
      expect(read("app/views/admin/components/index.js")).to include('export * from "terrazzo/components";')
      expect(read("app/views/admin/components/ui/index.js")).to include('export * from "terrazzo/ui";')
    end
  end

  it "builds standalone ejections by creating missing app-level barrels" do
    {
      "pages/index" => <<~JS,
        import AdminIndex from "./app/views/admin/application/index.jsx";
        import { AdminCollection } from "./app/views/admin/application/_collection.jsx";
        import { FieldRenderer } from "./app/views/admin/fields/index.js";
        import { ResourceTable } from "./app/views/admin/components/index.js";
        import { Button } from "./app/views/admin/components/ui/index.js";

        console.log(AdminIndex, AdminCollection, FieldRenderer, ResourceTable, Button);
      JS
      "components/SearchBar" => <<~JS,
        import { SearchBar } from "./app/views/admin/components/index.js";
        import { Input } from "./app/views/admin/components/ui/index.js";

        console.log(SearchBar, Input);
      JS
      "fields/string" => <<~JS,
        import { FieldRenderer, StringFormField } from "./app/views/admin/fields/index.js";
        import { Input } from "./app/views/admin/components/ui/index.js";

        console.log(FieldRenderer, StringFormField, Input);
      JS
    }.each do |target, entry|
      reset_destination_root
      run_generator(described_class, [target])
      create_node_package_link
      create_file "standalone_entry.jsx", entry

      expect_bundle_to_succeed("standalone_entry.jsx")
    end
  end

  it "keeps ejected implementation files on app-owned UI and component imports" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    %w[pages/index pages/show pages/new pages/edit].each do |target|
      run_generator(described_class, [target])
    end
    component_names.each do |name|
      run_generator(described_class, ["components/#{name}"])
    end
    field_names.each do |name|
      run_generator(described_class, ["fields/#{name}"])
    end
    run_generator(Terrazzo::Generators::FieldGenerator, ["Rating"])

    jsx_files = Dir[File.join(destination_root, "app/views/admin/**/*.jsx")]
    forbidden_imports = jsx_files.flat_map do |path|
      source = File.read(path)
      source.scan(/from ["']terrazzo\/(?:ui|components)["']/).map do |match|
        "#{path.delete_prefix("#{destination_root}/")}: #{match}"
      end
    end

    expect(forbidden_imports).to be_empty
    expect(read("app/views/admin/components/Pagination.jsx")).to include('from "./ui"')
    expect(read("app/views/admin/fields/has_many/ShowField.jsx")).to include('from "../../components"')
    expect(read("app/views/admin/fields/rating/FormField.jsx")).to include('from "../../components/ui"')
  end

  it "registers resource-specific pages in the generated page manifest" do
    create_file "app/javascript/admin/page_to_page_mapping.js", <<~JS
      import { customPageMapping } from "./custom_page_mapping";
      const pages = { ...customPageMapping };
      export const pageToPageMapping = pages;
    JS

    run_generator(Terrazzo::Generators::Views::IndexGenerator, ["User"])

    mapping = read("app/javascript/admin/page_to_page_mapping.js")
    expect(mapping).to include('import { generatedPageMapping } from "./generated_page_mapping";')
    expect(mapping).to include("...generatedPageMapping")

    manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(manifest).to include("Add manual custom pages to custom_page_mapping.js instead.")
    expect(manifest).to include('import UserIndex from "../../views/admin/users/index";')
    expect(manifest).to include("'admin/users/index': UserIndex,")
  end

  it "repairs the main page mapping when the generated manifest already has the page" do
    create_file "app/javascript/admin/page_to_page_mapping.js", <<~JS
      import { customPageMapping } from "./custom_page_mapping";
      const pages = { ...customPageMapping };
      export const pageToPageMapping = pages;
    JS
    create_file "app/javascript/admin/generated_page_mapping.js", <<~JS
      // Resource-specific page mappings generated by Terrazzo.
      // Add manual custom pages to custom_page_mapping.js instead.

      // Terrazzo generated page imports start
      import UserIndex from "../../views/admin/users/index";
      // Terrazzo generated page imports end

      export const generatedPageMapping = {
        // Terrazzo generated page mappings start
        'admin/users/index': UserIndex,
        // Terrazzo generated page mappings end
      }
    JS

    run_generator(Terrazzo::Generators::Views::IndexGenerator, ["User"])

    mapping = read("app/javascript/admin/page_to_page_mapping.js")
    expect(mapping).to include('import { generatedPageMapping } from "./generated_page_mapping";')
    expect(mapping).to include("...generatedPageMapping")

    manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(manifest.scan("'admin/users/index': UserIndex,").size).to eq(1)
  end

  it "fails when a generated page mapping cannot be merged into the main mapping" do
    create_file "app/javascript/admin/page_to_page_mapping.js", <<~JS
      export const pageToPageMapping = {};
    JS

    expect { generate_resource_index_directly("User") }.to raise_error(
      Thor::Error,
      /could not find the pages object to merge it automatically/
    )
  end

  it "allows app-owned main mappings that already reference generated page mappings" do
    create_file "app/javascript/admin/page_to_page_mapping.js", <<~JS
      import { generatedPageMapping } from "./generated_page_mapping";
      export const pageToPageMapping = generatedPageMapping;
    JS

    run_generator(Terrazzo::Generators::Views::IndexGenerator, ["User"])

    mapping = read("app/javascript/admin/page_to_page_mapping.js")
    expect(mapping.scan("generatedPageMapping").size).to eq(2)

    manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(manifest).to include('import UserIndex from "../../views/admin/users/index";')
    expect(manifest).to include("'admin/users/index': UserIndex,")
  end

  it "preserves manual custom page mappings when registering resource-specific pages" do
    create_file "app/javascript/admin/page_to_page_mapping.js", <<~JS
      import { customPageMapping } from "./custom_page_mapping";
      const pages = { ...customPageMapping };
      export const pageToPageMapping = pages;
    JS
    create_file "app/javascript/admin/custom_page_mapping.js", <<~JS
      // Manual custom page mappings for pages you own.
      import ReportsIndex from "../../views/admin/reports/index";

      export const customPageMapping = {
        'admin/reports/index': ReportsIndex,
      }
    JS

    run_generator(Terrazzo::Generators::Views::IndexGenerator, ["User"])

    manual_manifest = read("app/javascript/admin/custom_page_mapping.js")
    expect(manual_manifest).to include('import ReportsIndex from "../../views/admin/reports/index";')
    expect(manual_manifest).to include("'admin/reports/index': ReportsIndex,")
    expect(manual_manifest).not_to include("UserIndex")

    generated_manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(generated_manifest).to include('import UserIndex from "../../views/admin/users/index";')
    expect(generated_manifest).to include("'admin/users/index': UserIndex,")
    expect(generated_manifest).to include("// Terrazzo generated page imports end")
    expect(generated_manifest).to include("// Terrazzo generated page mappings end")
  end

  it "lets form page generators eject counterparts non-interactively" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    run_generator(Terrazzo::Generators::Views::NewGenerator, ["Invoice", "--with-counterpart"])
    run_generator(Terrazzo::Generators::Views::EditGenerator, ["Refund", "--no-with-counterpart"])

    expect(File).to exist(File.join(destination_root, "app/views/admin/invoices/new.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/invoices/edit.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/invoices/_form.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/invoices/new.json.props"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/invoices/edit.json.props"))

    expect(File).to exist(File.join(destination_root, "app/views/admin/refunds/edit.jsx"))
    expect(File).to exist(File.join(destination_root, "app/views/admin/refunds/_form.jsx"))
    expect(File).not_to exist(File.join(destination_root, "app/views/admin/refunds/new.jsx"))
    expect(File).not_to exist(File.join(destination_root, "app/views/admin/refunds/new.json.props"))

    manifest = read("app/javascript/admin/generated_page_mapping.js")
    expect(manifest).to include("'admin/invoices/new': InvoiceNew,")
    expect(manifest).to include("'admin/invoices/edit': InvoiceEdit,")
    expect(manifest).to include("'admin/refunds/edit': RefundEdit,")
    expect(manifest).not_to include("'admin/refunds/new':")
  end

  it "keeps legacy view subgenerators compatible with ejection" do
    run_generator(Terrazzo::Generators::ViewsGenerator, [])

    run_generator(Terrazzo::Generators::Views::FieldGenerator, ["money"])
    run_generator(Terrazzo::Generators::Views::FieldGenerator, ["all"])
    run_generator(Terrazzo::Generators::Views::LayoutGenerator, [])
    run_generator(Terrazzo::Generators::Views::NavigationGenerator, [])

    create_node_package_link
    write_legacy_subgenerator_entry

    expect_bundle_to_succeed("legacy_subgenerator_entry.jsx")

    fields_barrel = read("app/views/admin/fields/index.js")
    expect(fields_barrel).to include('export * from "terrazzo/fields";')
    expect(fields_barrel).to include('registerNumberFieldType("number"')
    expect(fields_barrel).to include('registerAssetFieldType("asset"')
    expect(read("app/views/admin/components/index.js")).to include("setLayout(Layout);")
    expect(read("app/views/admin/components/index.js")).to include('export { AppSidebar } from "./app-sidebar";')
    expect(read("app/views/admin/application/_navigation.json.props")).to include("navigation_resources")
  end

  it "keeps field ejection templates aligned with packaged field components" do
    packaged_fields = field_component_directories("npm/src/fields")
    template_fields = field_component_directories("lib/generators/terrazzo/views/templates/fields")

    expect(template_fields).to eq(packaged_fields)
    expect(field_top_level_template_files).to be_empty

    packaged_fields.each do |field_name|
      packaged_files = field_component_files("npm/src/fields", field_name)
      template_files = field_component_files("lib/generators/terrazzo/views/templates/fields", field_name)

      expect(template_files).to eq(packaged_files)

      packaged_files.each do |relative_path|
        packaged_source = read_repo("npm/src/fields/#{field_name}/#{relative_path}")
        template_source = read_repo("lib/generators/terrazzo/views/templates/fields/#{field_name}/#{relative_path}")

        expect(normalize_ejected_field_source(template_source)).to eq(normalize_ejected_field_source(packaged_source)),
          "expected fields/#{field_name}/#{relative_path} to match the packaged component"
      end
    end
  end

  it "keeps component ejection templates aligned with packaged components" do
    packaged_files = component_template_files("npm/src/components")
    template_files = component_template_files("lib/generators/terrazzo/views/templates/components")

    expect(template_files).to eq(packaged_files)

    packaged_files.each do |file_name|
      packaged_source = read_repo("npm/src/components/#{file_name}")
      template_source = read_repo("lib/generators/terrazzo/views/templates/components/#{file_name}")

      expect(normalize_ejected_component_source(template_source)).to eq(normalize_ejected_component_source(packaged_source)),
        "expected components/#{file_name} to match the packaged component"
    end
  end

  private

  def run_generator(generator, args)
    original_stdout = $stdout
    output = StringIO.new
    $stdout = output
    generator.start(args, destination_root: destination_root)
    output.string
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

  def write_smoke_entry
    create_file "entry.jsx", <<~JS
      import "./app/views/admin/fields/index.js";
      import "./app/views/admin/components/index.js";
      import "./app/views/admin/components/ui/index.js";
      import AdminIndex from "./app/views/admin/application/index.jsx";
      import AdminShow from "./app/views/admin/application/show.jsx";
      import AdminNew from "./app/views/admin/application/new.jsx";
      import AdminEdit from "./app/views/admin/application/edit.jsx";
      import { FieldRenderer } from "./app/views/admin/fields/index.js";
      import { FormField as RatingFormField } from "./app/views/admin/fields/rating/FormField.jsx";
      import { Layout, ResourceTable } from "./app/views/admin/components/index.js";
      import { Button } from "./app/views/admin/components/ui/index.js";

      console.log(AdminIndex, AdminShow, AdminNew, AdminEdit, FieldRenderer, RatingFormField, Layout, ResourceTable, Button);
    JS
  end

  def write_resource_view_entry
    create_file "resource_entry.jsx", <<~JS
      import "./app/views/admin/fields/index.js";
      import "./app/views/admin/components/index.js";
      import "./app/views/admin/components/ui/index.js";
      import { generatedPageMapping } from "./app/javascript/admin/generated_page_mapping.js";
      import OrderIndex from "./app/views/admin/orders/index.jsx";
      import OrderShow from "./app/views/admin/orders/show.jsx";
      import OrderNew from "./app/views/admin/orders/new.jsx";
      import PaymentEdit from "./app/views/admin/payments/edit.jsx";

      console.log(generatedPageMapping, OrderIndex, OrderShow, OrderNew, PaymentEdit);
    JS
  end

  def write_standalone_resource_view_entry
    create_file "standalone_resource_entry.jsx", <<~JS
      import "./app/views/admin/fields/index.js";
      import "./app/views/admin/components/index.js";
      import "./app/views/admin/components/ui/index.js";
      import { FieldRenderer } from "./app/views/admin/fields/index.js";
      import { ResourceTable } from "./app/views/admin/components/index.js";
      import { Button } from "./app/views/admin/components/ui/index.js";
      import { generatedPageMapping } from "./app/javascript/admin/generated_page_mapping.js";
      import OrderIndex from "./app/views/admin/orders/index.jsx";
      import OrderShow from "./app/views/admin/orders/show.jsx";
      import InvoiceNew from "./app/views/admin/invoices/new.jsx";
      import InvoiceEdit from "./app/views/admin/invoices/edit.jsx";
      import PaymentEdit from "./app/views/admin/payments/edit.jsx";

      console.log(
        FieldRenderer,
        ResourceTable,
        Button,
        generatedPageMapping,
        OrderIndex,
        OrderShow,
        InvoiceNew,
        InvoiceEdit,
        PaymentEdit
      );
    JS
  end

  def write_all_components_entry
    imports = expected_component_exports.values.join(", ")

    create_file "all_components_entry.jsx", <<~JS
      import "./app/views/admin/components/ui/index.js";
      import { #{imports} } from "./app/views/admin/components/index.js";

      console.log(#{imports});
    JS
  end

  def write_component_entry
    create_file "component_entry.jsx", <<~JS
      import "./app/views/admin/fields/index.js";
      import "./app/views/admin/components/ui/index.js";
      import * as Components from "./app/views/admin/components/index.js";

      console.log(Components);
    JS
  end

  def write_ui_entry
    create_file "ui_entry.jsx", <<~JS
      import * as Ui from "./app/views/admin/components/ui/index.js";

      console.log(Ui);
    JS
  end

  def write_fields_entry
    create_file "fields_entry.jsx", <<~JS
      import * as Fields from "./app/views/admin/fields/index.js";

      console.log(Fields);
    JS
  end

  def write_legacy_subgenerator_entry
    create_file "legacy_subgenerator_entry.jsx", <<~JS
      import "./app/views/admin/fields/index.js";
      import "./app/views/admin/components/index.js";
      import "./app/views/admin/components/ui/index.js";
      import { FieldRenderer, NumberIndexField } from "./app/views/admin/fields/index.js";
      import { Layout, AppSidebar } from "./app/views/admin/components/index.js";

      console.log(FieldRenderer, NumberIndexField, Layout, AppSidebar);
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

  def create_file(relative_path, content)
    path = File.join(destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def reset_destination_root
    FileUtils.rm_rf(destination_root)
    FileUtils.mkdir_p(destination_root)
  end

  def read(relative_path)
    File.read(File.join(destination_root, relative_path))
  end

  def eject_directly(target)
    described_class.new([target], {}, destination_root: destination_root).eject
  end

  def generate_resource_index_directly(resource)
    original_stdout = $stdout
    $stdout = StringIO.new
    Terrazzo::Generators::Views::IndexGenerator
      .new([resource], {}, destination_root: destination_root)
      .copy_index_template
  ensure
    $stdout = original_stdout
  end

  def read_repo(relative_path)
    File.read(File.join(repo_root, relative_path))
  end

  def field_component_directories(relative_root)
    Dir[File.join(repo_root, relative_root, "*")]
      .select { |path| File.directory?(path) }
      .map { |path| File.basename(path) }
      .sort
  end

  def field_top_level_template_files
    Dir[File.join(repo_root, "lib/generators/terrazzo/views/templates/fields/*")]
      .select { |path| File.file?(path) }
      .map { |path| File.basename(path) }
      .sort
  end

  def field_component_files(relative_root, field_name)
    root = File.join(repo_root, relative_root, field_name)
    Dir[File.join(root, "**", "*")]
      .select { |path| File.file?(path) }
      .map { |path| path.delete_prefix("#{root}/") }
      .sort
  end

  def component_template_files(relative_root)
    Dir[File.join(repo_root, relative_root, "*.jsx")]
      .map { |path| File.basename(path) }
      .reject { |name| name.end_with?(".test.jsx") }
      .sort
  end

  def normalize_ejected_field_source(source)
    source
      .gsub(
        /import \{ getComponent \} from "\.\.\/\.\.\/componentRegistry";\nimport \{ ResourceTable as DefaultResourceTable \} from "\.\.\/\.\.\/components\/ResourceTable";\nimport \{ HasManyPagination as DefaultHasManyPagination \} from "\.\.\/\.\.\/components\/HasManyPagination";/,
        'import { ResourceTable, HasManyPagination } from "__TERRAZZO_COMPONENTS__";'
      )
      .gsub(/  const ResourceTable = getComponent\("ResourceTable"\) \|\| DefaultResourceTable;\n  const HasManyPagination = getComponent\("HasManyPagination"\) \|\| DefaultHasManyPagination;\n/, "")
      .gsub(/from "terrazzo\/ui"/, 'from "__TERRAZZO_UI__"')
      .gsub(/from "\.\.\/\.\.\/components\/ui"/, 'from "__TERRAZZO_UI__"')
      .gsub(/from "terrazzo\/components"/, 'from "__TERRAZZO_COMPONENTS__"')
      .gsub(/from "\.\.\/\.\.\/components"/, 'from "__TERRAZZO_COMPONENTS__"')
      .gsub(/\n{2,}/, "\n")
      .strip
  end

  def normalize_ejected_component_source(source)
    source
      .gsub(/import \{ getComponent \} from "\.\.\/componentRegistry";\n/, "")
      .gsub(/ as Default([A-Za-z0-9_]+)/, "")
      .gsub(/  const [A-Za-z0-9_]+ = getComponent\("[A-Za-z0-9_]+"\) \|\| Default[A-Za-z0-9_]+;\n/, "")
      .gsub(/from "\.\.\/utils"/, 'from "terrazzo"')
      .gsub(/from "terrazzo\/ui"/, 'from "__TERRAZZO_UI__"')
      .gsub(/from "\.\/ui"/, 'from "__TERRAZZO_UI__"')
      .gsub(/from "terrazzo\/fields"/, 'from "__TERRAZZO_FIELDS__"')
      .gsub(/from "\.\.\/fields"/, 'from "__TERRAZZO_FIELDS__"')
      .gsub(/\n{2,}/, "\n")
      .strip
  end

  def component_names
    expected_component_exports.keys.sort
  end

  def field_names
    field_component_directories("lib/generators/terrazzo/views/templates/fields").reject { |name| name == "shared" }
  end

  def field_uses_shared_text_input?(name)
    %w[string number email url password date date_time time].include?(name)
  end

  def ui_component_names
    Dir[File.join(repo_root, "lib/generators/terrazzo/views/templates/components/ui/*.jsx")]
      .map { |path| File.basename(path, ".jsx") }
      .sort
  end

  def ui_dependencies_for(name)
    {
      "pagination" => %w[button],
      "sidebar" => %w[button input separator sheet skeleton tooltip],
    }.fetch(name, [])
  end

  def ui_exports_for(name)
    source = File.read(File.join(repo_root, "lib/generators/terrazzo/views/templates/components/ui/index.js"))
    match = source.match(/^export\s*\{(?<exports>[^}]*)\}\s*from\s*["']\.\/#{Regexp.escape(name)}["'];/m)
    raise "Missing UI export fixture for #{name}" unless match

    match[:exports].split(",").map(&:strip).reject(&:empty?).join(", ")
  end

  def component_dependencies_for(name)
    {
      "Layout" => %w[app-sidebar site-header FlashMessages],
      "ResourceTable" => %w[SortableHeader CollectionItemActions],
    }.fetch(name, [])
  end

  def expected_component_exports
    {
      "CollectionFilters" => "CollectionFilters",
      "CollectionItemActions" => "CollectionItemActions",
      "CollectionToolbarActions" => "CollectionToolbarActions",
      "FlashMessages" => "FlashMessages",
      "HasManyPagination" => "HasManyPagination",
      "Layout" => "Layout",
      "Pagination" => "Pagination",
      "ResourceTable" => "ResourceTable",
      "SearchBar" => "SearchBar",
      "SortableHeader" => "SortableHeader",
      "app-sidebar" => "AppSidebar",
      "site-header" => "SiteHeader",
    }
  end

  def esbuild_bin
    File.join(repo_root, "npm/node_modules/.bin/esbuild")
  end
end
