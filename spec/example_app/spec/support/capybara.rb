require "capybara/rspec"

Capybara.default_max_wait_time = 10
Capybara.server = :puma, {Silent: true}

RSpec.configure do |config|
  config.before(:each, type: :system) do
    if ENV["HEADED"]
      driven_by :selenium, using: :chrome, screen_size: [1280, 800]
    else
      driven_by :selenium, using: :headless_chrome, screen_size: [1280, 800]
    end
  end
end
