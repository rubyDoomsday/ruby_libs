# frozen_string_literal: true

require "rest_client"
require "uri"

require_relative "response"
require_relative "../parsers/xml"

# @abstract Rest::Http::Client provides a wrapper for dealing with external HTTP
#   calls to restful APIs and returns a Rest::Http::Response object or raises an
#   error if the downstream server is not available.
#
# @author Rebecca Chapin <rchapin@growpath.com>
#
# @attr_accessor [String] host        The base url for the API
# @attr_accessor [String] schema      The HTTP schema, defaults to https
# @attr_accessor [Hash]   credentials The API user/password used to access the API
module Rest
  module Http
    class Client
      class FiveHundredError < StandardError; end

      attr_reader :host, :schema, :credentials

      # @param [String] host The FQDN of the API host url (ie. http://api.com)
      # @param [Hash]   options Additional Client parameters
      # @option options [String] :schema      Force http schema. defaults to https
      # @option options [Hash]   :credentials { user: [uid], password: [password] }
      def initialize(host, **options)
        @host        = host
        @schema      = options.fetch(:schema, "https")
        @credentials = options.fetch(:credentials, {})
      end

      # @param [String] path The path to the API resource
      # @param [Hash]   opts additional options
      # @option :headers [Hash] Additional or overriding headers
      # @option :params [Hash] Additional url params
      # @return [Rest::Http::Response]
      def get(path, opts = {})
        Response.new(do_request(:get, path, opts: opts))
      end

      # @param [String] path The path to the API resource
      # @param [Hash]   body The payload to be posted to the API
      # @param [Hash]   opts Additional options for the request @see do_request
      # @return [Rest::Http::Response]
      def post(path, body, opts = {})
        Response.new(do_request(:post, path, body: body, opts: opts))
      end

      # @param [String] path The path to the API resource
      # @return [Rest::Http::Response]
      def delete(path, opts = {})
        Response.new(do_request(:delete, path, opts: opts))
      end

      private

      # @param [Hash] opts Additional options and overrides
      # @option opts [Hash] :headers Additional headers needed for the request
      # @option opts [Hash] :params  Params to be added to the URL for the request
      def do_request(action, path, body: {}, opts: {})
        request = {
          method:  action,
          url:     url(path, opts.fetch(:params, {})),
          headers: headers.merge(opts.fetch(:headers, {})),
          timeout: 180,
        }

        request = request.merge(payload: body) unless body.blank?
        request = request.merge(credentials) unless credentials.blank?

        RestClient::Request.execute(request)
      rescue RestClient::InternalServerError => e
        Rails.logger.error("Downstream Server Failure: #{e.message}")
        raise FiveHundredError, e.response.body
      rescue RestClient::ExceptionWithResponse => e
        Rails.logger.warn("Rest Client Response: #{e.message}")
        e.response
      end

      def headers
        {
          accept:       :json,
          content_type: :json
        }
      end

      def url(path, params = {})
        # force schema regardless of the host passed in
        domain =
          if schema.match(/https/)
            host.sub(/^http:/i, "#{schema}:")
          else
            host.sub(/^https:/i, "#{schema}:")
          end

        params = URI.encode_www_form(params)
        path = path + "?" + params unless params.empty?

        URI.join(domain, path).to_s
      end
    end
  end
end
