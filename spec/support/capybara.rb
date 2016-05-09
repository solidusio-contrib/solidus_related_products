require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/poltergeist'
require 'capybara-screenshot/rspec'

RSpec.configure do |config|
  Capybara.register_driver(:poltergeist) do |app|
    Capybara::Poltergeist::Driver.new app, js_errors: true, timeout: 90
  end
  Capybara.javascript_driver = :poltergeist
  Capybara.default_max_wait_time = 10

  Capybara.save_and_open_page_path = ENV['CIRCLE_ARTIFACTS'] if ENV['CIRCLE_ARTIFACTS']

  config.before(:each, :js) do
    if Capybara.javascript_driver == :selenium
      page.driver.browser.manage.window.maximize
    end
  end
end
