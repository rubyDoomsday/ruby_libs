# frozen_string_literal: true

# @abstract Rest::Party::Base provides the base configuration and HTTP client
#   for all inheriting parties. Child class should provide a method for each
#   endpoint required for accessing the API
#
# @author Rebecca Chapin <rchapin@growpath.com>
#
# @attr_accessor [Rest::Party::Config] config The Party configuration details
module Rest
  module Party
    class Base
      def self.config
        @config ||= Rest::Party::Config.new
      end

      def self.configure
        yield config
      end

      attr_accessor :config

      # @param [Rest::Party::Config] config The party configuration
      def initialize(config = nil)
        @config = config.nil? ? self.class.config : config
      end

      def client
        @client ||= Rest::Http::Client.new(config.host, config.options)
      end
    end
  end
end
