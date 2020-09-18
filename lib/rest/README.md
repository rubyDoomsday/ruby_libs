# Parties

3rd parties are meant to be a singleton cofiguration that can be accessed through
the rails application. The following is an example configuration/initializer for
the two example parties.

```ruby
# /config/intializers/rest_parties.rb

# frozen_string_literal: true

require_relative "../../lib/rest/party"

cronofy_configuration = Rails.application.config_for(:cronofy)
Rest::Party::Cronofy.configure do |c|
  c.host      = cronofy_configuration.host
  c.client_id = cronofy_configuration.client_id
  c.token     = cronofy_configuration.client_secret
end

twilio_configuration = Rails.application.config_for(:twilio)
Rest::Party::Twilio.configure do |c|
  c.host      = twilio_configuration.host
  c.client_id = twilio_configuration.account_sid
  c.token     = twilio_configuration.auth_token
  c.options   = {
    credentials: {
      user:     twilio_configuration.account_sid,
      password: twilio_configuration.auth_token,
    }
  }
end
```
