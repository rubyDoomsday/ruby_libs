# frozen_string_literal: true

# @abstract Rest::Http::Response is a wrapper class for an HTTP response and
#   provides some convenience methods for reading and inspecting a response
#   from a 3rd party API
#
# @author Rebecca Chapin <rchapin@growpath.com>
#
# @attr_reader [HTTP::Response] resp The raw HTTP response from the underlying HTTP library
require "json"

module Rest
  module Http
    class ResponseBodyError < StandardError; end

    class Response
      attr_reader :resp
      alias raw resp

      # @param [HTTP::Resposne] resp An API HTTP response
      def initialize(resp)
        @resp = resp
      end

      def raw
        resp
      end

      # @return [Boolean]
      def success?
        resp.code >= 200 && resp.code < 300
      end

      # @return [Boolean]
      def failed?
        resp.code >= 400
      end

      # @return [Integer]
      def code
        resp.code
      end

      # @return [Hash]
      def headers
        resp.headers
      end

      # @return [String]
      def body
        resp.body
      end

      # json returns a best effort parsing of a JSON API response
      # @return [Hash] eg. { key: 'value', key: { key: 'value' } }
      def json
        JSON.parse(resp.body, symbolize_names: true)
      rescue StandardError => e
        Rails.logger.error("JSON parse failure: #{e.message}")
        raise ResponseBodyError, e.message
      end

      # xml returns a best effort parsing of an XML API response
      # @return [Rest::Parsers::Xml] ie. a wrapper for the REXML library.
      def xml
        Parsers::Xml.new(resp.body)
      end
    end
  end
end
