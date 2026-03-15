ENV["RAILS_ENV"] = "test"

# Point to the example app
require File.expand_path("example_app/config/environment", __dir__)

require "rspec/rails"

# Load support files
Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
end
