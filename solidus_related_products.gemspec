lib = File.expand_path('../lib/', __FILE__)
$LOAD_PATH.unshift lib unless $LOAD_PATH.include?(lib)

require 'solidus_related_products/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'solidus_related_products'
  s.version     = SolidusRelatedProducts.version
  s.summary     = 'Allows multiple types of relationships between products to be defined'
  s.description = s.summary
  s.required_ruby_version = '>= 2.1.0'

  s.author       = 'Brian Quinn'
  s.email        = 'brian@railsdog.com'
  s.homepage     = 'https://github.com/solidusio-contrib/solidus_related_products'
  s.license      = 'BSD-3'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_runtime_dependency 'solidus_backend', ['>= 1.0', '< 3']
  s.add_runtime_dependency 'solidus_support'
  s.add_runtime_dependency 'deface', '~> 1.0'

  s.add_development_dependency 'factory_bot', '~> 4.5'
  s.add_development_dependency 'ffaker'
  s.add_development_dependency 'rspec-rails', '~> 3.4'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'capybara', '~> 2.5'
  s.add_development_dependency 'capybara-screenshot', '~> 1.0'
  s.add_development_dependency 'poltergeist', '~> 1.9'
  s.add_development_dependency 'shoulda-matchers', '~> 2.5'
  s.add_development_dependency 'simplecov', '~> 0.9'
  s.add_development_dependency 'database_cleaner', '~> 1.3'
  s.add_development_dependency 'rubocop', '>= 0.24.1'
  s.add_development_dependency 'rspec-activemodel-mocks'
end
