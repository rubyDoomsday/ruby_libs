# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Party::Twilio do
  let(:subject) { described_class.new }

  before(:each) do
    Rest::Party::Twilio.configure do |c|
      c.host      = "http://twilio.com"
      c.client_id = "account_sid"
      c.token     = "auth_token"
      c.options   = {
        credentials: {
          user:     "account_sid",
          password: "auth_token"
        }
      }
    end
  end

  it "has a call endpoint" do
    expect(subject.calls).to be_instance_of(described_class::Calls)
  end

  it "has a messages endpoint" do
    expect(subject.messages).to be_instance_of(described_class::Messages)
  end

  describe "#calls" do
    let(:to) { "+18675309" }
    let(:params) do
      {
        webhook: "https://webhook.url",
        to:      to,
        from:    "+19198675309"
      }
    end

    let(:body) { build(:outbound_call)}

    it '#create (without extension)' do
      stub = stub_request(:post, /Calls/).
               with(body: 'Url=https%3A%2F%2Fwebhook.url&To=%2B18675309&From=%2B19198675309').
               to_return(status: 200, body: body.to_json)
      resp = subject.calls.create(params)
      expect(stub).to have_been_requested
      expect(resp.success?).to eq true
      expect(resp.json).to eq body
      expect(resp.json[:to]).to eq body[:to]
    end

    it "#create (with extension)" do
      params.merge!(extension: "1234")
      stub = stub_request(:post, /Calls/).
               with(body: "Url=https%3A%2F%2Fwebhook.url&To=%2B18675309&From=%2B19198675309&SendDigits=1234").
               to_return(status: 200, body: body.to_json)
      resp = subject.calls.create(params)
      expect(resp.success?).to eq true
      expect(resp.json).to eq body
      expect(resp.json[:to]).to eq body[:to]
    end

    it "#list" do
      body = build(:inbound_call_list)

      stub_request(:get, /Calls/).
              with(query: {"Status" => "in-progress", "To" => "15558675310"}).
              to_return(status: 200, body: body.to_json)

      resp = subject.calls.list(params: {"Status" => "in-progress", "To" => "15558675310"})
      expect(resp.json).to eq body
    end
  end

  describe "#messages" do
    let(:to) { "+18675309" }
    let(:params) do
      {
        to:   to,
        from: "+19198675309",
        msg:  "hello world"
      }
    end

    let(:body) { build(:outbound_sms) }

    before(:each) do
      stub_request(:post, /Messages/).to_return(status: 200, body: body.to_json)
    end

    it "#create" do
      resp = subject.messages.create(params)
      expect(resp.success?).to eq true
      expect(resp.json).to eq body
      expect(resp.json[:to]).to eq body[:to]
    end
  end
end
