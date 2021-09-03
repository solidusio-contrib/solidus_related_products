# frozen_string_literal: true

require_relative 'lib/solidus_related_products/version'

Gem::Specification.new do |spec|
  spec.name = 'solidus_related_products'
  spec.version = SolidusRelatedProducts::VERSION
  spec.authors = ['Brian Quinn']
  spec.email = 'brian@railsdog.com'

  spec.summary = 'Allows multiple types of relationships between products to be defined'
  spec.description = 'Allows multiple types of relationships between products to be defined'
  spec.homepage = 'https://github.com/solidusio-contrib/solidus_related_products'
  spec.license = 'BSD-3-Clause'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/solidusio-contrib/solidus_related_products'
  spec.metadata['changelog_uri'] = 'https://github.com/solidusio-contrib/solidus_related_products/blob/master/CHANGELOG.md'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5')

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  files = Dir.chdir(__dir__) { `git ls-files -z`.split("\x0") }

  spec.files = files.grep_v(%r{^(test|spec|features)/})
  spec.test_files = files.grep(%r{^(test|spec|features)/})
  spec.bindir = "exe"
  spec.executables = files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'solidus_core', '>= 2.0.0', '< 4'
  spec.add_dependency 'solidus_backend', '>= 2.0.0', '< 4'
  spec.add_dependency 'solidus_support', '~> 0.5'
  spec.add_dependency 'deface', '~> 1.0'

  spec.add_development_dependency 'solidus_dev_support', '~> 2.3'
  spec.add_development_dependency 'autoprefixer-rails', '~> 10.3.3'
  spec.add_development_dependency 'rspec-activemodel-mocks'
  spec.add_development_dependency 'shoulda-matchers'
  spec.add_development_dependency 'webdrivers'
end
