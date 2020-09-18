# frozen_string_literal: true

module Rest
  module Party
    class Cronofy < Base
      def calendars
        @calendars ||= Calendars.new(self)
      end

      def events
        @events ||= Events.new(self)
      end

      def channels
        @channels ||= Channels.new(self)
      end

      def auth
        @auth ||= Auth.new(self)
      end

      private

      Calendars = Struct.new(:party) do
        # @param token [String] The User Access token received during oauth2 handshake
        def list(token:)
          url = "#{party.config.host}/v1/calendars"

          party.client.get(url, headers: auth_headers(token))
        end

        # @param token [String] The User Access token received during oauth2 handshake
        # @param name  [String] The familiar name of the calendar
        # @param profile_id [String] The UUID of the calendar
        def create(token:, name:, profile_id:)
          body = { name: name, profile_id: profile_id, color: gp_green }
          url = "#{party.config.host}/v1/calendars"
          headers = { content_type: "application/x-www-form-urlencoded" }

          party.client.post(url, body, headers: auth_headers(token).merge(headers))
        end

        private

        def auth_headers(token)
          @auth_headers ||= { authorization: "Bearer #{token}" }
        end

        def gp_green
          "#659700"
        end
      end

      Events = Struct.new(:party) do
        # @param token [String] The User Access token received during oauth2 handshake
        # @param calendar_id [String] The Cronofy ID for the calendar
        # @param event [Hash] The cronofy-ied event hash parameters (see: events_spec.rb)
        def create(token:, calendar_id:, event:)
          body = event
          url = "#{party.config.host}/v1/calendars/#{calendar_id}/events"
          headers = { content_type: "application/x-www-form-urlencoded" }

          party.client.post(url, body, headers: auth_headers(token).merge(headers))
        end
        # Cronofy events are an upsert action so create/update behave the same
        alias_method :update, :create

        # @param token [String] The User Access token received during oauth2 handshake
        # @param last_modified [String] The last modified date as an ISO8601 formatted string
        # @param calendar_ids [Array] Scope to specific calendar IDs ([] = all calendars' events)
        def read(token:, last_modified:, calendar_ids:)
          params = {
            last_modified:   last_modified,
            tzid:            tzid,
            include_managed: true,
            include_deleted: true
          }.to_param

          url = "#{party.config.host}/v1/events?#{params}"
          url += calendar_ids.map { |c| "&calendar_ids[]=#{c}" }.join unless calendar_ids.empty?

          paginated_request(url, token)
        end

        # @param token [String] The User Access token received during oauth2 handshake
        # @param calendar_id [String] The Cronfoy ID for the calendar
        # @param event_id [String] The Cronfoy ID for the event
        def delete(token:, calendar_id:, event_id:)
          url = "#{party.config.host}/v1/calendars/#{calendar_id}/events?event_id=#{event_id}"
          party.client.delete(url, headers: auth_headers(token))
        end

        private

        def paginated_request(url, token)
          events, page, total = [], 0, 1 # rubocop:disable Style/ParallelAssignment

          while page < total
            resp = party.client.get(url, headers: auth_headers(token))
            return resp unless resp.success?

            meta  = resp.json[:pages]
            page  = meta[:current]
            total = meta[:total]
            url   = meta[:next_page]

            events += resp.json[:events]
          end

          # maintains Rest::Client contract
          raw = OpenStruct.new(code:    resp.code,
                               headers: resp.headers,
                               body:    { events: events }.to_json)
          Rest::Http::Response.new(raw)
        end

        def tzid
          Time.zone.tzinfo.name
        end

        def auth_headers(token)
          @auth_headers ||= { authorization: "Bearer #{token}" }
        end
      end

      Channels = Struct.new(:party) do
        # @param token [String] The User Access token received during oauth2 handshake
        def list(token:)
          url = "#{party.config.host}/v1/channels"

          party.client.get(url, headers: auth_headers(token))
        end

        # @param token [String] The User Access token received during oauth2 handshake
        # @param calendar_id [String] The Cronofy ID for the calendar
        # @param event_id [String] The App defined callback URL the channel POSTs to
        def create(token:, calendar_ids:, callback_url:)
          url = "#{party.config.host}/v1/channels"
          headers = { content_type: "application/x-www-form-urlencoded" }
          body = channel(calendar_ids, callback_url)

          party.client.post(url, body, headers: auth_headers(token).merge(headers))
        end

        # @param token [String] The User Access token received during oauth2 handshake
        # @param channel_id [String] The Cronofy ID for the channel
        def delete(token:, channel_id:)
          url = "#{party.config.host}/v1/channels/#{channel_id}"

          party.client.delete(url, headers: auth_headers(token))
        end

        private

        def channel(calendar_ids, callback_url)
          {
            callback_url: callback_url,
            filters:      {
              calendar_ids: calendar_ids,
              only_managed: true # we only want PNs for events originating in GP app
            }
          }
        end

        def auth_headers(token)
          @auth_headers ||= { authorization: "Bearer #{token}" }
        end
      end

      Auth = Struct.new(:party) do
        # @param refresh_token [String] The User Refresh token received during oauth2 handshake
        def refresh(refresh_token:)
          url = "#{party.config.host}/oauth/token"
          headers = { content_type: "application/x-www-form-urlencoded" }

          party.client.post(url, body(refresh_token), headers: headers)
        end

        def revoke(access_token:)
          url = "#{party.config.host}/oauth/token/revoke"
          headers = { content_type: "application/x-www-form-urlencoded" }

          party.client.post(url, revoke_body(access_token), headers: headers)
        end

        private

        def body(token)
          {
            client_id:     party.config.client_id,
            client_secret: party.config.client_secret,
            grant_type:    "refresh_token",
            refresh_token: token
          }
        end

        def revoke_body(access_token)
          {
            client_id:     party.config.client_id,
            client_secret: party.config.client_secret,
            token:         access_token
          }
        end
      end
    end
  end
end
