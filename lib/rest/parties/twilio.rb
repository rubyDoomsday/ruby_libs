# frozen_string_literal: true

require_relative "base"

module Rest
  module Party
    # NOTE: Twilio JSON and URL params MUST be capitalized
    class Twilio < Base
      def calls
        @calls ||= Calls.new(self)
      end

      def messages
        @messages ||= Messages.new(self)
      end

      private

      Calls = Struct.new(:party) do
        # @param [String] webhook   The location of the TWIML instructions to perform on connection
        # @param [String] to        The destination phone number ie +19198675309
        # @param [String] from      The number to appear on the caller id ie +19198675309
        # @param [String] extension The extension of the destination ("w" for every .5 second delay)
        def create(webhook:, to:, from:, extension: nil)
          url  = "#{party.config.host}/#{party.config.client_id}/Calls.json"
          body = { "Url" => webhook, "To" => to, "From" => from }
          headers = { content_type: "application/x-www-form-urlencoded" }

          # NOTE: "#" is not url safe but may be used in an extension. CGI.escape permits it to pass
          body["SendDigits"] = CGI.escape(extension) unless extension.nil?

          party.client.post(url, body, headers: headers)
        end

        def list(params: {})
          url = "#{party.config.host}/#{party.config.client_id}/Calls.json"

          party.client.get(url, params: params)
        end
      end

      Messages = Struct.new(:party) do
        # @param [String] to   The destination phone number ie +19198675309
        # @param [String] from The number to appear on the caller id ie +19198675309
        # @param [String] msg  The SMS message body
        def create(from:, to:, msg:)
          url  = "#{party.config.host}/#{party.config.client_id}/Messages.json"
          body = { "From" => from, "To" => to, "Body" => msg }
          headers = { content_type: "application/x-www-form-urlencoded" }

          party.client.post(url, body, headers: headers)
        end
      end
    end
  end
end
