# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

branch = ENV.fetch('SOLIDUS_BRANCH', 'main')
gem 'solidus', github: 'solidusio/solidus', branch: branch

# The solidus_frontend gem has been pulled out since v3.2
if branch >= 'v3.2'
  gem 'solidus_frontend'
elsif branch == 'main'
  gem 'solidus_frontend', github: 'solidusio/solidus_frontend'
else
  gem 'solidus_frontend', github: 'solidusio/solidus', branch: branch
end

# solidus_legacy_promotions was extracted from solidus_core in v4.4. Pull it from
# the same monorepo so the engine's legacy-promotions registration path is loaded
# and exercised by the engine spec.
if branch == 'main' || branch >= 'v4.4'
  gem 'solidus_legacy_promotions',
      github: 'solidusio/solidus',
      branch: branch,
      glob: 'legacy_promotions/*.gemspec'
end

gem 'coffee-rails', '~> 5.0'

rails_version = ENV.fetch('RAILS_VERSION', '7.2')
gem 'rails', "~> #{rails_version}"

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3', '~> 2.0'
end

gem 'rspec-rails', '~> 6.0.3', require: false
gem 'database_cleaner', '~> 2.0', require: false

gemspec

if Gem::Version.new(RUBY_VERSION) >= Gem::Version.new('3')
  # Fix for Rails 7+ / Ruby 3+, see https://stackoverflow.com/a/72474475
  gem 'net-imap', require: false
  gem 'net-pop', require: false
  gem 'net-smtp', require: false
end

# Use a local Gemfile to include development dependencies that might not be
# relevant for the project or for other contributors, e.g. pry-byebug.
#
# We use `send` instead of calling `eval_gemfile` to work around an issue with
# how Dependabot parses projects: https://github.com/dependabot/dependabot-core/issues/1658.
send(:eval_gemfile, 'Gemfile-local') if File.exist? 'Gemfile-local'
