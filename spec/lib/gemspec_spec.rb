RSpec.describe "terrazzo.gemspec" do
  let(:gemspec_path) { File.expand_path("../../terrazzo.gemspec", __dir__) }
  let(:specification) { Gem::Specification.load(gemspec_path) }

  it "packages documentation and license files" do
    expect(specification.files).to include("README.md")
    expect(specification.files).to include("LICENSE")
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
