# frozen_string_literal: true

source "https://rubygems.org"

branch = ENV.fetch('SOLIDUS_BRANCH', 'master')
gem "solidus", git: "https://github.com/solidusio/solidus.git", branch: branch

gem 'factory_bot', (branch < 'v2.5' ? '4.10.0' : '> 4.10.0'), group: :test

if ENV['DB'] == 'mysql'
  gem 'mysql2', '~> 0.4.10'
else
  gem 'pg', '~> 1.1'
end

group :development, :test do
  gem "pry-rails"
end

gemspec
