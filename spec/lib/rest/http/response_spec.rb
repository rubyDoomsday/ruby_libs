# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Http::Response do
  let(:body) { { sample: "body" } }

  describe "Success (200) response" do
    let(:resp) { double("http_response", code: 200, body: body.to_json) }
    let(:subject) { described_class.new(resp) }

    it "is a success" do
      expect(subject.success?).to eq true
      expect(subject.failed?).to eq false
    end

    it "parses JSON to hash" do
      expect(subject.json).to eq body
    end

    let(:xml) { %(<Hello attr="hi"><Inner>Greetings Friend</Inner></Hello>) }
    let(:xml_resp) { double("http_response", code: 200, body: xml) }
    let(:xml_subject) { described_class.new(xml_resp) }

    it "parses XML" do
      parsed_xml = xml_subject.xml

      expect(parsed_xml).to be_a(Rest::Parsers::Xml)
      expect(parsed_xml.first("//Hello").name).to eq("Hello")
    end
  end

  describe "Failure (400) response" do
    let(:resp) { double("http_response", code: 400, body: "http text body") }
    let(:subject) { described_class.new(resp) }

    it "is not a success" do
      expect(subject.success?).to eq false
      expect(subject.failed?).to eq true
    end

    it "raises error if not JSON" do
      expect { subject.json }.to raise_error(Rest::Http::ResponseBodyError)
    end
  end
end
