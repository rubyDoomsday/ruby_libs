# frozen_string_literal: true

# Provided only to keep specs plug and play for rails projects
require_relative "../env.rb"
require_relative "spec_helper"

Dir[Rails.root.join("spec/support/**/*.rb")].sort.each { |f| require f }
