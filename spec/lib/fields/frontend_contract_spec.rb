require "spec_helper"

RSpec.describe "field frontend contract" do
  let(:repo_root) { File.expand_path("../../..", __dir__) }

  it "maps every built-in Ruby field to a shipped frontend field type" do
    frontend_field_types = Dir[File.join(repo_root, "npm/src/fields/*")]
      .select { |path| File.directory?(path) }
      .map { |path| File.basename(path) }

    ruby_field_types = Dir[File.join(repo_root, "lib/terrazzo/field/*.rb")]
      .map { |path| File.basename(path, ".rb") }
      .reject { |name| Terrazzo::Field::Base::ABSTRACT_FIELD_CLASSES.map(&:underscore).include?(name) }
      .map do |name|
        require "terrazzo/field/#{name}"
        Terrazzo::Field.const_get(name.camelize).field_type
      end
      .uniq

    expect(ruby_field_types - frontend_field_types).to eq([])
  end
end
