# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require File.expand_path('./spec_helper', __dir__)
require 'selenium-webdriver'

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/test/fixtures"
  config.include FactoryBot::Syntax::Methods

  config.before :suite do
    chrome_options = {
      #
      # NOTE: When using Chrome headress, default window size is 800x600.
      # In case window size is not specified, Redmine renderes its contents with responsive mode.
      #
      args: %w[window-size=1280,800]
    }
    if ENV['DRIVER'] == 'headless'
      chrome_options[:args].concat(%w[headless disable-gpu])
    end

    Capybara.register_driver :headless_chrome do |app|
      capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
        'goog:chromeOptions': chrome_options
      )
      Capybara::Selenium::Driver.new(
        app,
        browser: :chrome,
        capabilities: [capabilities]
      )
    end
  end

  config.before :each, type: :feature do
    Capybara.javascript_driver = :headless_chrome
    Capybara.current_driver = :headless_chrome
    Capybara.default_max_wait_time = 30
  end

  config.include Capybara::DSL
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end
