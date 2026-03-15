RSpec.configure do |config|
  config.before(:suite) do
    # Build JS and CSS assets before running system specs.
    # Skip if assets are already built (e.g., in CI where a prior step handles it).
    build_dir = Rails.root.join("app/assets/builds")
    js_built = Dir.glob(build_dir.join("*.js")).any?
    css_built = Dir.glob(build_dir.join("*.css")).any?

    unless js_built && css_built
      puts "\n== Building assets for system specs =="
      system("npm run build", chdir: Rails.root.to_s, exception: true)
    end
  end
end
