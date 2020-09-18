# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Parsers::Xml do
  let(:xml_string) do
    %(
      <Foo attributefoo="valuefoo">
        <Bar attributebar="valuebar" attributeblarg="valueblarg">
          BarContent
        </Bar>
      </Foo>
    )
  end

  it "successfully parses XML strings" do
    xml_parser = described_class.new(xml_string)

    expect { xml_parser.first("/") }.not_to raise_error
  end

  let(:xml_io) do
    StringIO.new(xml_string)
  end

  it "successfully parses XML IO objects" do
    xml_parser = described_class.new(xml_io)

    expect { xml_parser.first("/") }.not_to raise_error
  end

  let(:xml_rexml_document) do
    REXML::Document.new(xml_string)
  end

  it "successfully parses REXML::Document objects" do
    xml_parser = described_class.new(xml_rexml_document)

    expect { xml_parser.first("/") }.not_to raise_error
  end

  context "public methods" do
    let(:xml_parser) { described_class.new(xml_string) }

    it "#first" do
      first = xml_parser.first("//Foo")

      expect(first).to be_a(REXML::Element)
      expect(first.name).to eq("Foo")
    end

    it "#each" do
      all = xml_parser.each("//Foo", &:itself)

      expect(all).to be_a(Array)
      expect(all.first.name).to eq("Foo")
    end

    it "#match" do
      matched = xml_parser.match("//Foo")

      expect(matched).to be_a(Array)
      expect(matched.first.name).to eq("Foo")
    end
  end

  context "invalid XML" do
    let(:invalid_xml) do
      %(
        <Foo attributefoo="valuefoo">
          <Bar attributebar="valuebar">
            BarContent
          </Whoops>
        </UhOh>
      )
    end

    it "raises an error if it's passed invalid XML" do
      xml_parser = described_class.new(invalid_xml)

      expect { xml_parser.first("/") }.to raise_error(Rest::Http::ResponseBodyError)
    end
  end
end
