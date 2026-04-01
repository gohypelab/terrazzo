require_relative "lib/terrazzo/version"

Gem::Specification.new do |spec|
  spec.name = "terrazzo"
  spec.version = Terrazzo::VERSION
  spec.authors = ["Terrazzo Contributors"]
  spec.email = []
  spec.summary = "A Rails admin framework powered by Superglue and React"
  spec.description = "Drop-in admin panel for Rails apps using the Administrate dashboard DSL with a React SPA frontend powered by Superglue."
  spec.homepage = "https://github.com/gohypelab/terrazzo"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1"

  spec.files = Dir[
    "app/**/*",
    "config/**/*",
    "lib/**/*",
    "LICENSE",
    "Rakefile",
    "terrazzo.gemspec"
  ]
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.1"
  spec.add_dependency "kaminari", "~> 1.2"
  spec.add_dependency "superglue", "~> 1.1"
  spec.add_dependency "form_props", ">= 0.0.6"

  spec.add_development_dependency "rspec-rails", "~> 7.0"
  spec.add_development_dependency "factory_bot_rails", "~> 6.0"
  spec.add_development_dependency "sqlite3", ">= 2.1"
end
