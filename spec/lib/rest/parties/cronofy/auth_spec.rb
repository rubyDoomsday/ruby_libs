# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Party::Cronofy do
  let(:subject) { described_class.new }

  before(:each) do
    Rest::Party::Cronofy.configure do |c|
      c.host      = "http://cronofy.com"
      c.client_id = "client_id"
      c.token     = "client_secret"
    end
  end

  it "has an auth endpoint" do
    expect(subject.auth).to be_instance_of(described_class::Auth)
  end

  context "#auth" do
    # Pulled from: https://docs.cronofy.com/developers/api/authorization/refresh-token/
    let(:response) do
      {
        token_type:    "bearer",
        access_token:  "P531x88i05Ld2yXHIQ7WjiEyqlmOHsgI",
        expires_in:    3600,
        refresh_token: "REFRESH_TOKEN",
        scope:         "create_event delete_event"
      }
    end

    let(:refresh_body) do
      {
        client_id:     "client_id",
        client_secret: "client_secret",
        grant_type:    "refresh_token",
        refresh_token: "REFRESH_TOKEN"
      }
    end

    describe "#refresh" do
      it "handles 200 (Success) response" do
        stub = stub_request(:post, /oauth/).
                 with(body: refresh_body).
                 to_return(status: 200, body: response.to_json)
        resp = subject.auth.refresh(refresh_token: "REFRESH_TOKEN")

        expect(stub).to have_been_requested
        expect(resp.success?).to eq true
        expect(resp.json).to eq response
      end

      it "handles 4XX (Failed) response" do
        stub = stub_request(:post, /oauth/).
                 with(body: refresh_body).
                 to_return(status: 400, body: { error: "invalid grant" }.to_json)
        resp = subject.auth.refresh(refresh_token: "REFRESH_TOKEN")

        expect(stub).to have_been_requested
        expect(resp.success?).to eq false
        expect(resp.json[:error]).to be_present
      end
    end

    describe "#revoke" do
      it "handles 200 (Success) response" do
        stub = stub_request(:post, /oauth/).to_return(status: 200, body: "")
        resp = subject.auth.revoke(access_token: "ACCESS_TOKEN")

        expect(stub).to have_been_requested
        expect(resp.success?).to eq true
      end

      it "handles 4XX (Failed) response" do
        stub = stub_request(:post, /oauth/).
                 to_return(status: 400, body: { error: "invalid" }.to_json)
        resp = subject.auth.revoke(access_token: "ACCESS_TOKEN")

        expect(stub).to have_been_requested
        expect(resp.success?).to eq false
        expect(resp.json[:error]).to be_present
      end
    end
  end
end
