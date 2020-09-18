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

  it "has a events endpoint" do
    expect(subject.events).to be_instance_of(described_class::Events)
  end

  context "#events" do
    # Pulled From: https://docs.cronofy.com/developers/api/events/upsert-event/
    # Pulled From: https://docs.cronofy.com/developers/api/events/delete-event/
    let(:response) { "" }
    let(:event_params) do
      {
        calendar_id: "theIDofANamedCalendarInTheProvider",
        event:       {
          event_id:    "event_id",
          start:       Time.now.iso8601,
          end:         Time.now.iso8601,
          summary:     "summary",
          description: "description",
          tzid:        Time.zone.tzinfo.name,
          location:    { description: "location" },
          attendees:   [
            {
              email:        "email@email.com",
              display_name: "name",
            },
          ],
        },
      }
    end

    let(:page_1) do
      {
        pages:  {
          current:   1,
          total:     2,
          next_page: "https://api.cronofy.com/v1/events/pages/nextID"
        },
        events: [
          {
            calendar_id:          "cal_number1",
            event_uid:            "evt-id-number1",
            summary:              "Company Retreat",
            description:          "",
            start:                "2014-09-06",
            end:                  "2014-09-08",
            deleted:              false,
            created:              "2019-11-05T08:00:01Z",
            updated:              "2019-11-05T09:24:16Z",
            participation_status: "needs_action",
            transparency:         "opaque",
            status:               "confirmed",
            categories:           [],
            recurring:            false,
            event_private:        false,
            location:             {
              description: "Beach"
            },
            attendees:            [
              {
                email:        "example@cronofy.com",
                display_name: "Example Person",
                status:       "needs_action"
              }
            ],
            organizer:            {
              email:        "example@cronofy.com",
              display_name: "Example Person"
            },
            options:              {
              delete:                      true,
              update:                      true,
              change_participation_status: true
            }
          }
        ]
      }
    end

    let(:page_2) do
      {
        pages:  {
          current:   2,
          total:     2,
          next_page: ""
        },
        events: [
          {
            calendar_id:          "cal_number1",
            event_uid:            "evt-id-number2",
            summary:              "Company Retreat",
            description:          "",
            start:                "2014-09-06",
            end:                  "2014-09-08",
            deleted:              false,
            created:              "2019-11-05T08:00:01Z",
            updated:              "2019-11-05T09:24:16Z",
            participation_status: "needs_action",
            transparency:         "opaque",
            status:               "confirmed",
            categories:           [],
            recurring:            false,
            event_private:        false,
            location:             {
              description: "Beach"
            },
            attendees:            [
              {
                email:        "example@cronofy.com",
                display_name: "Example Person",
                status:       "needs_action"
              }
            ],
            organizer:            {
              email:        "example@cronofy.com",
              display_name: "Example Person"
            },
            options:              {
              delete:                      true,
              update:                      true,
              change_participation_status: true
            }
          }
        ]
      }
    end

    describe "#create" do
      it "handles 202 (Success) response" do
        stub_request(:post, /events/).to_return(status: 202, body: response)
        resp = subject.events.create(params.merge(event_params))

        expect(resp.success?).to eq true
        expect(resp.code).to eq 202
        expect { resp.json }.to raise_error Rest::Http::ResponseBodyError
      end

      it "handles 4XX (Failed) response" do
        stub_request(:post, /events/).
          to_return(status: 400, body: { errors: { tzid: "required" } }.to_json)
        resp = subject.events.create(params.merge(event_params))

        expect(resp.success?).to eq false
        expect(resp.code).to eq 400
        expect(resp.json[:errors]).to be_present
      end
    end

    describe "#update" do
      it "handles 202 (Success) response" do
        stub_request(:post, /events/).to_return(status: 202, body: response)
        resp = subject.events.update(params.merge(event_params))

        expect(resp.success?).to eq true
        expect(resp.code).to eq 202
        expect { resp.json }.to raise_error Rest::Http::ResponseBodyError
      end

      it "handles 4XX (Failed) response" do
        stub_request(:post, /events/).
          to_return(status: 400, body: { errors: { tzid: "required" } }.to_json)
        resp = subject.events.update(params.merge(event_params))

        expect(resp.success?).to eq false
        expect(resp.code).to eq 400
        expect(resp.json[:errors]).to be_present
      end
    end

    describe "#delete" do
      it "handles 202 (Success) response" do
        delete_params = { calendar_id: "someCalendarID", event_id: "someEventId" }
        stub_request(:delete, /events/).to_return(status: 202, body: response)
        resp = subject.events.delete(params.merge(delete_params))

        expect(resp.success?).to eq true
        expect(resp.code).to eq 202
        expect { resp.json }.to raise_error Rest::Http::ResponseBodyError
      end

      it "handles 4XX (Failed) response" do
        delete_params = { calendar_id: "someCalendarID", event_id: "someEventId" }
        stub_request(:delete, /events/).
          to_return(status: 400, body: { errors: { tzid: "required" } }.to_json)
        resp = subject.events.delete(params.merge(delete_params))

        expect(resp.success?).to eq false
        expect(resp.code).to eq 400
        expect(resp.json[:errors]).to be_present
      end
    end

    describe "#read" do
      it "200 (Success) - returns paginated request" do
        read_params = { calendar_ids: [], last_modified: Time.now.utc.iso8601 }
        stub = stub_request(:get, /events/).
                 to_return(status: 200, body: page_1.to_json).then.
                 to_return(status: 200, body: page_2.to_json)
        resp = subject.events.read(params.merge(read_params))

        expect(stub).to have_been_requested.times(2)
        expect(resp.success?).to eq true
        expect(resp.code).to eq 200
        expect(resp.json[:events].count).to eq 2
        expect(resp.json[:events].first[:event_uid]).to eq "evt-id-number1"
        expect(resp.json[:events].last[:event_uid]).to eq "evt-id-number2"
      end

      it "400 (Invalid) - paginated request fails" do
        read_params = { calendar_ids: [], last_modified: Time.now.utc.iso8601 }
        stub = stub_request(:get, /events/).
                 to_return(status: 400,
                           body:   { errors: { tzid: [key: "errors.required"] } }.to_json)
        resp = subject.events.read(params.merge(read_params))

        expect(stub).to have_been_requested.times(1)
        expect(resp.success?).to eq false
        expect(resp.code).to eq 400
      end
    end
  end
end
