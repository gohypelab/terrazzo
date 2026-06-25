require "fileutils"
require "pathname"
require "stringio"
require "tmpdir"

require "generators/terrazzo/routes/routes_generator"

RSpec.describe Terrazzo::Generators::RoutesGenerator do
  let(:destination_root) { Dir.mktmpdir("terrazzo-routes-generator") }

  after do
    FileUtils.remove_entry(destination_root)
  end

  it "points the admin root at a namespaced controller when only namespaced models exist" do
    create_file "config/routes.rb", <<~RUBY
      Rails.application.routes.draw do
      end
    RUBY

    with_destination_rails_root do
      generator = routes_generator
      allow(generator).to receive(:application_models).and_return([Blog::Post, Blog::Tag])

      capture_stdout { generator.insert_routes }
    end

    routes = read("config/routes.rb")
    expect(routes).to eq(<<~RUBY)
      Rails.application.routes.draw do
        namespace :admin do
          namespace :blog do
            resources :posts
            resources :tags
          end

          root to: "blog/posts#index"
        end
      end
    RUBY
    expect(routes).not_to include('root to: "posts#index"')
  end

  it "generates nested route namespaces for deeply namespaced models" do
    create_file "config/routes.rb", <<~RUBY
      Rails.application.routes.draw do
      end
    RUBY

    with_destination_rails_root do
      generator = routes_generator
      deep_model = double("Store::Catalog::Product", name: "Store::Catalog::Product")
      allow(generator).to receive(:application_models).and_return([deep_model])

      capture_stdout { generator.insert_routes }
    end

    routes = read("config/routes.rb")
    expect(routes).to eq(<<~RUBY)
      Rails.application.routes.draw do
        namespace :admin do
          namespace :store do
            namespace :catalog do
              resources :products
            end
          end

          root to: "store/catalog/products#index"
        end
      end
    RUBY
    expect(routes).not_to include("namespace :store/catalog")
  end

  it "inserts a cleanly indented admin namespace for top-level models" do
    create_file "config/routes.rb", <<~RUBY
      Rails.application.routes.draw do
      end
    RUBY

    with_destination_rails_root do
      generator = routes_generator
      allow(generator).to receive(:application_models).and_return([Customer])

      capture_stdout { generator.insert_routes }
    end

    routes = read("config/routes.rb")
    expect(routes).to eq(<<~RUBY)
      Rails.application.routes.draw do
        namespace :admin do
          resources :customers

          root to: "customers#index"
        end
      end
    RUBY
  end

  it "prints the namespaced admin root target when the namespace already exists" do
    create_file "config/routes.rb", <<~RUBY
      Rails.application.routes.draw do
        namespace :admin do
        end
      end
    RUBY

    output = with_destination_rails_root do
      generator = routes_generator
      allow(generator).to receive(:application_models).and_return([Blog::Post])

      capture_stdout { generator.insert_routes }
    end

    expect(output).to include('root to: "blog/posts#index"')
    expect(output).to include("  namespace :blog do")
    expect(output).to include("    resources :posts")
    expect(output).not_to include('root to: "posts#index"')
  end

  it "fails instead of routing admin root to a missing dashboard when no models exist" do
    create_file "config/routes.rb", <<~RUBY
      Rails.application.routes.draw do
      end
    RUBY

    with_destination_rails_root do
      generator = routes_generator
      allow(generator).to receive(:application_models).and_return([])

      expect { capture_stdout { generator.insert_routes } }
        .to raise_error(Thor::Error, /could not find any ApplicationRecord models/)
    end
  end

  private

  def routes_generator
    described_class.new([], {}, destination_root: destination_root)
  end

  def with_destination_rails_root(&block)
    allow(Rails).to receive(:root).and_return(Pathname.new(destination_root))
    block.call
  end

  def create_file(relative_path, content)
    path = File.join(destination_root, relative_path)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def read(relative_path)
    File.read(File.join(destination_root, relative_path))
  end

  def capture_stdout
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end
end
