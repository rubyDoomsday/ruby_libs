# frozen_string_literal: true

FactoryBot.define do
  # From https://www.twilio.com/docs/voice/api/call-resource?code-sample=code-read-multiple-call-resources-and-filter-by-call-status-and-phone-number&code-language=curl&code-sdk-version=json
  factory :inbound_call_list, class: Hash do
    calls { [] }
    add_attribute(:end) { 1 }
    first_page_uri { "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls.json?Status=completed&To=%2B123456789&From=%2B987654321&StartTime=2008-01-02&ParentCallSid=CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&EndTime=2009-01-02&PageSize=2&Page=0" }
    next_page_uri { "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls.json?Status=completed&To=%2B123456789&From=%2B987654321&StartTime=2008-01-02&ParentCallSid=CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&EndTime=2009-01-02&PageSize=2&Page=1&PageToken=PACAaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa0" }
    page { 0 }
    page_size { 2 }
    previous_page_uri { "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls.json?Status=completed&To=%2B123456789&From=%2B987654321&StartTime=2008-01-02&ParentCallSid=CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&EndTime=2009-01-02&PageSize=2&Page=0" }
    start { 0 }
    uri { "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls.json?Status=completed&To=%2B123456789&From=%2B987654321&StartTime=2008-01-02&ParentCallSid=CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX&EndTime=2009-01-02&PageSize=2&Page=0" }

    initialize_with { attributes }
    after(:build)  do |call_hash|
      2.times do |n|
        call_hash[:calls] << build(:inbound_call, caller_name: "Caller #{n}")
      end
    end
  end

  factory :inbound_call, class: Hash do
    account_sid { "ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
    annotation { "billingreferencetag1" }
    answered_by { "machine_start" }
    api_version { "2010-04-01" }
    caller_name { "callerid1" }
    date_created { "Fri, 18 Oct 2019 17:00:00 +0000" }
    date_updated { "Fri, 18 Oct 2019 17:01:00 +0000" }
    direction { "outbound-api" }
    duration { "4" }
    end_time { "Fri, 18 Oct 2019 17:03:00 +0000" }
    forwarded_from { "calledvia1" }
    from { "+13058416799" }
    from_formatted { "(305) 841-6799" }
    group_sid { "GPXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
    parent_call_sid { SecureRandom.uuid }
    phone_number_sid { "PNXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
    price { "-0.200" }
    price_unit { "USD" }
    sid { "CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
    start_time { "Fri, 18 Oct 2019 17:02:00 +0000" }
    status { "completed" }
    subresource_uris {{
      "feedback": "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls/CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Feedback.json",
      "feedback_summaries": "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls/FeedbackSummary.json",
      "notifications": "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls/CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Notifications.json",
      "recordings": "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls/CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Recordings.json",
      "payments": "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls/CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Payments.json"
    }}
    to { "+13051913581" }
    to_formatted { "(305) 191-3581" }
    trunk_sid { "TRXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
    uri { "/2010-04-01/Accounts/ACXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX/Calls/CAXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX.json" }
    queue_time { "1000" }

    initialize_with { attributes }
  end

  # From https://www.twilio.com/docs/voice/api/call?code-sample=code-create-a-call&code-language=Ruby&code-sdk-version=5.x
  factory :outbound_call, class: Hash do
    account_sid      { "ACSID" }
    api_version      { "2010-04-01" }
    date_created     { "Tue, 31 Aug 2010 20:36:28 +0000" }
    date_updated     { "Tue, 31 Aug 2010 20:36:44 +0000" }
    direction        { "inbound" }
    duration         { "15" }
    end_time         { "Tue, 31 Aug 2010 20:36:44 +0000" }
    forwarded_from   { "+141586753093" }
    from             { "+15017122661" }
    from_formatted   { "(501) 712-2661" }
    phone_number_sid { "PNNUMSID" }
    price            { -0.03000 }
    price_unit       { "USD" }
    sid              { "CASID" }
    start_time       { "Tue, 31 Aug 2010 20:36:29 +0000" }
    status           { "completed" }
    to               { "+15558675310" }
    to_formatted     { "(555) 867-5310" }
    uri              { "/2010-04-01/Accounts/ACSID/Calls/CASID.json" }
    subresource_uris {{
      "notifications":      "/2010-04-01/Accounts/ACSID/Calls/CASID/Notifications.json",
      "recordings":         "/2010-04-01/Accounts/ACSID/Calls/CASID/Recordings.json",
      "feedback":           "/2010-04-01/Accounts/ACSID/Calls/CASID/Feedback.json",
      "feedback_summaries": "/2010-04-01/Accounts/ACSID/Calls/FeedbackSummary.json"
    }}

    initialize_with { attributes }
  end
end
