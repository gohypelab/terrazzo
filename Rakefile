require "bundler/gem_tasks"

begin
  require "rspec/core/rake_task"
  RSpec::Core::RakeTask.new(:spec) do |t|
    t.pattern = "spec/lib/**/*_spec.rb"
  end
  task default: :spec
rescue LoadError
  # rspec not available
end
