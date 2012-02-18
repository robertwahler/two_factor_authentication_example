RailsApp
========

An example application for the AuthlogicTwoFactor Gem

Creating RailsApp
-----------------

rails version

    rails -v

        Rails 3.2.1

generate basic rails application

    rails new rails_app --skip-bundle -T

Gemfile

    gem "authlogic", "~> 3.1.0"

    group :test, :development do
      gem "ruby-debug"
      gem "rspec-rails", "~> 2.8"
      gem "factory_girl_rails", "~> 1.6"
      gem "capybara", "~> 1.1"
      gem "cucumber-rails", "~> 1.2"
      gem "database_cleaner", "~> 0.7.1"
      gem "timecop", "= 0.3.5"
    end

Gemfile.lock

    bundle update

run cucumber and rspec generators

    rails generate rspec:install
    rails generate cucumber:install --rspec --capybara

Updating RailsApp
-----------------

    rails new .
