# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Party::Cronofy do
  let(:subject) { described_class.new }
  let(:access_token) { "oauth2-access-token" }
  let(:params) { { token: access_token } }

  before(:each) do
    Rest::Party::Cronofy.configure do |c|
      c.host      = "http://cronofy.com"
      c.client_id = "client_id"
      c.token     = "client_secret"
    end
  end

  it "has a calender endpoint" do
    expect(subject.calendars).to be_instance_of(described_class::Calendars)
  end

  context "#calendars" do
    # Pulled from: https://docs.cronofy.com/developers/api/calendars/list-calendars/
    let(:list_body) do
      {
        "calendars": [
          {
            provider_name:     "google",
            profile_id:        "pro_n23kjnwrw2",
            profile_name:      "example@cronofy.com",
            calendar_id:       "cal_n23kjnwrw2_jsdfjksn234",
            calendar_name:     "Home",
            calendar_readonly: false,
            calendar_deleted:  false,
            calendar_primary:  true,
            permission_level:  "sandbox"
          },
          {
            provider_name:     "google",
            profile_id:        "pro_n23kjnwrw2",
            profile_name:      "example@cronofy.com",
            calendar_id:       "cal_n23kjnwrw2_n1k323nkj23",
            calendar_name:     "Work",
            calendar_readonly: true,
            calendar_deleted:  true,
            calendar_primary:  false,
            permission_level:  "sandbox"
          }
        ]
      }
    end

    # Pulled from: https://docs.cronofy.com/developers/api/calendars/create-calendar/
    let(:create_response) do
      {
        calendar: {
          provider_name:     "google",
          profile_id:        "pro_n23kjnwrw2",
          profile_name:      "example@cronofy.com",
          calendar_id:       "cal_n23kjnwrw2_sakdnawerd3",
          calendar_name:     "New Calendar",
          calendar_readonly: false,
          calendar_deleted:  false
        }
      }
    end

    describe "#list" do
      it "handles 200 (Success) response" do
        stub = stub_request(:get, /calendars/).
                 with(headers: { "Authorization" => "Bearer #{access_token}" }).
                 to_return(status: 200, body: list_body.to_json)
        resp = subject.calendars.list(params)

        expect(stub).to have_been_requested
        expect(resp.success?).to eq true
        expect(resp.json).to eq list_body
      end

      it "handles 4XX (Failed) response" do
        stub = stub_request(:get, /calendars/).
                 with(headers: { "Authorization" => "Bearer #{access_token}" }).
                 to_return(status: 400, body: { errors: { calendar_id: "not found" } }.to_json)
        resp = subject.calendars.list(params)

        expect(stub).to have_been_requested
        expect(resp.success?).to eq false
        expect(resp.json[:errors]).to be_present
      end
    end

    describe "#create" do
      it "handles 200 (Success) response" do
        params.merge!(name: "name", profile_id: "thisIsAProviderUUID")
        stub = stub_request(:post, /calendars/).
                 with(headers: { "Authorization" => "Bearer #{access_token}" },
                      body:    { name: "name", profile_id: "thisIsAProviderUUID", color: "#659700" }).
                 to_return(status: 200, body: create_response.to_json)
        resp = subject.calendars.create(params)

        expect(resp.success?).to eq true
        expect(resp.code).to eq 200
        expect(resp.json).to eq create_response
      end

      it "handles 4XX (Failed) response" do
        params.merge!(name: "name", profile_id: "thisIsAProviderUUID")
        stub_request(:post, /calendars/).
          with(headers: { "Authorization" => "Bearer #{access_token}" },
               body:    { name: "name", profile_id: "thisIsAProviderUUID", color: "#659700" }).
          to_return(status: 400, body: { errors: { name: "duplicate" } }.to_json)
        resp = subject.calendars.create(params)

        expect(resp.success?).to eq false
        expect(resp.json[:errors]).to be_present
      end
    end
  end
end
