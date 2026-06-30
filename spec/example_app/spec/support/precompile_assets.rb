RSpec.configure do |config|
  config.before(:suite) do
    # The admin panel is a build artifact (script/build_example_admin) — generated
    # from the Terrazzo generators + overlay/ and compiled to app/assets/builds.
    # It must be built BEFORE the app boots, because Rails autoloads the admin
    # controllers and dashboards at boot — so it cannot be generated from this
    # hook. Guard with a clear message instead.
    unless File.exist?(Rails.root.join("app/assets/builds/admin.js"))
      raise <<~MSG

        Admin panel not built. Run the recipe before the system specs:

            script/build_example_admin

        (The admin is generated from the Terrazzo generators + overlay/, not committed.)
      MSG
    end
  end
end
