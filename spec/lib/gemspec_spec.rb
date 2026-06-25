RSpec.describe "terrazzo.gemspec" do
  let(:root_path) { File.expand_path("../..", __dir__) }
  let(:gemspec_path) { File.join(root_path, "terrazzo.gemspec") }
  let(:specification) { Gem::Specification.load(gemspec_path) }

  it "packages documentation and license files" do
    expect(specification.files).to include("README.md")
    expect(specification.files).to include("LICENSE")
  end

  it "packages every runtime and generator file" do
    required_files = Dir.chdir(root_path) do
      Dir["app/**/*", "config/**/*", "lib/**/*"].select { |path| File.file?(path) }
    end

    expect(specification.files).to include(*required_files)
  end

  it "does not package development artifacts" do
    expect(specification.files).not_to include(a_string_matching(%r{\A(?:\.agents|\.github|docs|npm|pkg|spec)/}))
    expect(specification.files).not_to include(a_string_matching(%r{\Aterrazzo-\d+\.\d+\.\d+\.gem\z}))
  end

  it "publishes standard RubyGems metadata" do
    expect(specification.homepage).to eq("https://gohypelab.github.io/terrazzo/")
    expect(specification.metadata).to include(
      "homepage_uri" => "https://gohypelab.github.io/terrazzo/",
      "source_code_uri" => "https://github.com/gohypelab/terrazzo",
      "documentation_uri" => "https://gohypelab.github.io/terrazzo/getting-started",
      "changelog_uri" => "https://github.com/gohypelab/terrazzo/releases",
      "bug_tracker_uri" => "https://github.com/gohypelab/terrazzo/issues",
      "rubygems_mfa_required" => "true"
    )
  end
end
