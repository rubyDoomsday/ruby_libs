# frozen_string_literal: true

FactoryBot.define do
  # From https://www.twilio.com/console/api-explorer/sms/messages/create
  factory :outbound_sms, class: Hash do
    sid          { "SMb2ec3f0722914c43a86b5719d7db3c3c" }
    date_created { "Mon, 23 Sep 2019 19:49:59 +0000" }
    date_updated { "Mon, 23 Sep 2019 19:49:59 +0000" }
    account_sid  { "AC94802bb572c4b497b3bad24bb4e2747d" }
    to           { "+19198675309" }
    from         { "+15094867829" }
    body         { "Sent from your Twilio trial account - boom" }
    status       { "queued" }
    num_segments { "1" }
    num_media    { "0" }
    direction    { "outbound-api" }
    api_version  { "2010-04-01" }
    price_unit   { "USD" }

    initialize_with { attributes }
  end
end
