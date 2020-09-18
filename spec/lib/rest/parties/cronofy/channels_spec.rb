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

  it "hast a channels endpoint" do
    expect(subject.channels).to be_instance_of(described_class::Channels)
  end

  context "#channels" do
    let(:calendar_id) { "someCalendarID" }
    let(:callback_url) { "https://a-growpath-callback-url.com" }
    # Pulled from https://docs.cronofy.com/developers/api/push-notifications/create-channel/
    let(:channel) do
      {
        channel_id:   "chn_54cf7c7cb4ad4c1027000001",
        callback_url: callback_url,
        filters:      {
          calendar_ids: [calendar_id],
          only_managed: false
        }
      }
    end

    describe "#list" do
      it "handles 200 (Success) response" do
        stub_request(:get, /channels/).to_return(status: 200, body: { channels: [channel] }.to_json)
        resp = subject.channels.list(params)

        expect(resp.success?).to eq true
        expect(resp.code).to eq 200
        expect(resp.json[:channels].first).to eq channel
      end

      it "handles 4XX (Failed) response" do
        stub_request(:get, /channels/).
          to_return(status: 400, body: { errors: { auth: "unauthorized" } }.to_json)
        resp = subject.channels.list(params)

        expect(resp.success?).to eq false
        expect(resp.code).to eq 400
        expect(resp.json[:errors]).to be_present
      end
    end

    describe "#create" do
      it "handles 200 (Success) response" do
        stub_request(:post, /channels/).to_return(status: 200, body: { channel: channel }.to_json)
        resp = subject.channels.create(params.merge(calendar_ids: [calendar_id],
                                                    callback_url: callback_url))

        expect(resp.success?).to eq true
        expect(resp.code).to eq 200
        expect(resp.json[:channel]).to eq channel
      end

      it "handles 4XX (Failed) response" do
        stub_request(:post, /channels/).
          to_return(status: 400, body: { errors: { name: "duplicate" } }.to_json)
        resp = subject.channels.create(params.merge(calendar_ids: [calendar_id],
                                                    callback_url: callback_url))

        expect(resp.success?).to eq false
        expect(resp.json[:errors]).to be_present
      end
    end

    describe "#delete" do
      it "handles 200 (Success) response" do
        stub_request(:delete, /channels/).to_return(status: 202, body: "")
        resp = subject.channels.delete(params.merge(channel_id: "someChannelID"))

        expect(resp.success?).to eq true
        expect(resp.code).to eq 202
        expect { resp.json }.to raise_error Rest::Http::ResponseBodyError
      end

      it "handles 4XX (Failed) response" do
        stub_request(:delete, /channels/).
          to_return(status: 400, body: { errors: { channel_id: "not found" } }.to_json)
        resp = subject.channels.delete(params.merge(channel_id: "someChannelID"))

        expect(resp.success?).to eq false
        expect(resp.json[:errors]).to be_present
      end
    end
  end
end
