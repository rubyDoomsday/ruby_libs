# frozen_string_literal: true

APP_NAME = "ruby_libs"
ROOT = File.dirname(__dir__)

# Ensures everthing is loaded
require_relative "railsish/rails.rb"

# Application Snippets
require_relative "app/services/application_service"

# Libraries
require_relative "lib/phone_number/phone_number"
require_relative "lib/rest/party"
require_relative "lib/deep_clone"
