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

gem 'coffee-rails', '~> 5.0'

# Fetch the Rails version from the environment variable or default to '~> 7.0'
rails_version = ENV.fetch('RAILS_VERSION', '~> 7.0')
gem 'rails', rails_version

# Extract the minimum Rails version from the version requirement.
# For example, a requirement of "~> 7.0" translates to ">= 7.0" and "< 8.0".
rails_req = Gem::Requirement.new(rails_version)
# Find the minimum version specified by a ">=" constraint, if any.
min_rails_version = rails_req.requirements.find { |op, _| op == '>=' }&.last || Gem::Version.new('0')

# Determine the sqlite3 version based on the minimum Rails version.
# If the minimum Rails version is less than 7.2, use "~> 1.4"; otherwise, use "~> 2.0".
sqlite_version =
  if min_rails_version < Gem::Version.new('7.2')
    "~> 1.4"
  else
    "~> 2.0"
  end

case ENV['DB']
when 'mysql'
  gem 'mysql2'
when 'postgresql'
  gem 'pg'
else
  gem 'sqlite3', sqlite_version
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
