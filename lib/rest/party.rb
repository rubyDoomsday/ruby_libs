# frozen_string_literal: true

require_relative "http/client"

# Let's have a (3rd) party
require_relative "parties/twilio.rb"
require_relative "parties/cronofy.rb"

# @abstract Rest::Party provides an extensible interface for interacting
#   with 3rd party REST APIs. 3rd Party APIs live in the /parties path and
#   inherit from Rest::Party::Base.
#
# @author Rebecca Chapin <createive@rebeccachapin.com>
# @see /parties/twilio.rb for example of a party!
#
# @attr_accessor [Hash]   options Custom API configuration information
# @attr_accessor [String] host    The base url for the API
module Rest
  module Party
    class ConfigError < StandardError; end

    class Config
      attr_accessor :host, :client_id, :token, :options

      # @param opts [Hash]
      # @option opts [String] :host       The base url for accessing the API (ie. https://host.com/api)
      # @option opts [String] :client_id  The API account ID, client secret
      # @option opts [String] :token      The API Token
      def initialize(opts = {})
        @host        = opts.delete(:host)
        @token       = opts.delete(:token)
        @client_id   = opts.delete(:client_id)
        @options     = opts
      end

      # @return [Boolean] Validates the Party is configured
      def configured?
        return true unless host.nil?

        false
      end

      def client_secret
        @token
      end

      def client_secret=(client_secret)
        @token = client_secret
      end
    end
  end
end
