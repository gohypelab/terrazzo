require "spec_helper"
require "yaml"

RSpec.describe "release verification" do
  let(:root) { File.expand_path("../..", __dir__) }
  let(:ci) { YAML.load_file(File.join(root, ".github/workflows/ci.yml")) }
  let(:release) { YAML.load_file(File.join(root, ".github/workflows/release.yml")) }
  let(:commit_ref) { "${{ needs.resolve.outputs.sha }}" }

  it "makes the complete CI suite reusable for an explicit commit" do
    # Psych reads the GitHub Actions "on" key as a boolean.
    expect(ci.fetch(true).fetch("workflow_call").fetch("inputs").fetch("ref").fetch("type")).to eq("string")
    expect(ci.fetch("jobs").keys).to include("ruby", "npm", "docs", "system")

    ci.fetch("jobs").each_value do |job|
      expect(job).not_to have_key("if")
      expect(job).not_to have_key("continue-on-error")
      checkout = job.fetch("steps").find { |step| step["uses"].to_s.start_with?("actions/checkout@") }
      expect(checkout.fetch("with").fetch("ref")).to eq("${{ inputs.ref || github.sha }}")
      expect(job.fetch("steps")).to all(satisfy { |step| !step.key?("continue-on-error") })
    end
  end

  it "resolves a tag to a commit and passes it to the full CI workflow" do
    resolve = release.fetch("jobs").fetch("resolve")
    checkout = resolve.fetch("steps").find { |step| step["uses"].to_s.start_with?("actions/checkout@") }
    expect(checkout.fetch("with").fetch("ref")).to eq("refs/tags/${{ env.RELEASE_TAG }}")
    expect(resolve.fetch("outputs").fetch("sha")).to eq("${{ steps.release.outputs.sha }}")
    validation = resolve.fetch("steps").find { |step| step["id"] == "release" }
    expect(validation.fetch("run")).to include("git rev-parse HEAD", "gem_version", "npm_version")

    verify = release.fetch("jobs").fetch("verify")
    expect(verify.fetch("uses")).to eq("./.github/workflows/ci.yml")
    expect(verify.fetch("needs")).to eq("resolve")
    expect(verify.fetch("with").fetch("ref")).to eq(commit_ref)
  end

  %w[publish-gem publish-npm].each do |name|
    it "blocks #{name} unless full verification succeeds and publishes the verified commit" do
      publish = release.fetch("jobs").fetch(name)
      expect(publish.fetch("needs")).to contain_exactly("resolve", "verify")
      expect(publish).not_to have_key("if")
      expect(publish).not_to have_key("continue-on-error")
      checkout = publish.fetch("steps").find { |step| step["uses"].to_s.start_with?("actions/checkout@") }
      expect(checkout.fetch("with").fetch("ref")).to eq(commit_ref)
    end
  end

  it "runs the docs audit before building in CI and before deploying Pages" do
    docs = ci.fetch("jobs").fetch("docs")
    expect(docs.fetch("defaults").fetch("run").fetch("working-directory")).to eq("docs")
    expect(docs.fetch("steps")).to include(include("run" => "npm run check"))
    scripts = JSON.parse(File.read(File.join(root, "docs/package.json"))).fetch("scripts")
    expect(scripts.fetch("check")).to eq("npm audit --audit-level=moderate && npm run docs:build")

    pages = YAML.load_file(File.join(root, ".github/workflows/docs.yml"))
    expect(pages.fetch("jobs").fetch("build").fetch("steps"))
      .to include(include("working-directory" => "docs", "run" => "npm run check"))
    expect(pages.fetch("jobs").fetch("deploy").fetch("needs")).to eq("build")
  end
end
