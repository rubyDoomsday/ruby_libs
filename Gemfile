# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "2.6.5"

gem "rails"

group :development, :test do
  gem "pry-byebug"
  gem "rspec-rails"
  gem "rubocop"
end

group :development do
  gem "listen"
  gem "spring"
  gem "spring-watcher-listen"
  gem "web-console"
end

group :test do
  gem "factory_bot", "~> 5.0", ">= 5.0.2"
  gem "faker", "~> 2.1"
  gem "shoulda-matchers", "~> 4.2"
end
