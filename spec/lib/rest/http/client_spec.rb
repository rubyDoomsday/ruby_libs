# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Http::Client do
  let(:host) { "http://moo.net" }
  let(:path) { "/whats_to_eat" }
  let(:headers) { { "Content-Type" => "application/json", "Accept" => "application/json" } }

  let(:json) do
    {
      bessy:  "breakfast",
      dolly:  "lunch",
      borris: "dinner"
    }
  end

  let(:subject) { described_class.new(host) }

  it" forces the http schema" do
    subject = described_class.new("http://should_be_secured.net")
    expect(subject.send(:url, path, {})).to match("https:")

    subject = described_class.new("https://force_unsecure.net", schema: "http")
    expect(subject.send(:url, path, {})).to match("http:")

    subject = described_class.new("https://force_secure.net", schema: "https")
    expect(subject.send(:url, path, {})).to match("https:")

    subject = described_class.new("hTTp://case_insensitive.net", schema: "https")
    expect(subject.send(:url, path, {})).to match("https:")

    subject = described_class.new("http://more_than_one_http.net?http=param")
    expect(subject.send(:url, path, {})).to match("https:")
  end

  context "server failures" do
    it "400 - 499" do
      stub = stub_request(:post, /moo/).
               with(headers: headers).
               to_return(status: 400, body: { errors: "nogo my friend" }.to_json)
      body = { foo: "bar" }
      resp = subject.post(path, body.to_json)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq false
      expect(resp.json.keys).to eq [:errors]
    end

    it "500" do
      stub = stub_request(:post, /moo/).
               with(headers: headers).
               to_return(status: 500)
      body = { foo: "bar" }

      expect do
        subject.post(path, body.to_json)
      end.to raise_error(Rest::Http::Client::FiveHundredError)
      expect(stub).to have_been_requested.times(1)
    end

    it "301, 302, 307" do
      stub1 = stub_request(:get, /moved/).
                with(headers: headers).
                to_return(status: 301, headers: { "Location" => "http://moo.net.redirect" })
      stub2 = stub_request(:get, /redirect/).
                with(headers: headers).
                to_return(status: 200)
      params = { foo: "bar" }

      resp = subject.get("http://moo.net/moved", params)
      expect(stub1).to have_been_requested.times(1)
      expect(stub2).to have_been_requested.times(1)
      expect(resp.success?).to eq true
    end
  end

  describe "#post" do
    it "with body" do
      stub = stub_request(:post, /moo/).
               with(headers: headers).
               to_return(status: 200, body: json.to_json)
      body = { foo: "bar" }
      resp = subject.post(path, body.to_json)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq true
      expect(resp.json).to eq json.symbolize_keys
    end

    it "with opts" do
      stub = stub_request(:post, /moo/).
               with(headers: headers.merge("Content-Type" => "application/xml")).
               to_return(status: 200, body: "<xml></xml>")
      body = { foo: "bar" }
      opts = { headers: { content_type: "application/xml" } }
      resp = subject.post(path, body.to_xml, opts)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq true
      expect { resp.json }.to raise_error(Rest::Http::ResponseBodyError)
    end
  end

  describe "#get" do
    it "without params" do
      stub = stub_request(:get, /moo/).
               with(headers: headers).
               to_return(status: 200, body: json.to_json)
      resp = subject.get(path)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq true
      expect(resp.json).to eq json.symbolize_keys
    end

    it "with params" do
      stub = stub_request(:get, /moo/).
               with(headers: headers).
               to_return(status: 200, body: json.to_json)
      params = { foo: "bar" }
      resp = subject.get(path, params)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq true
    end
  end

  describe "#delete" do
    it "without params" do
      stub = stub_request(:delete, /moo/).
               with(headers: headers).
               to_return(status: 200, body: json.to_json)
      resp = subject.delete(path)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq true
      expect(resp.json).to eq json.symbolize_keys
    end

    it "with params" do
      stub = stub_request(:delete, /moo/).
               with(headers: headers).
               to_return(status: 200, body: json.to_json)
      params = { foo: "bar" }
      resp = subject.delete(path)

      expect(stub).to have_been_requested.times(1)
      expect(resp.success?).to eq true
    end
  end
end
