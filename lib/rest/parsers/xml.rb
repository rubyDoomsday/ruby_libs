# frozen_string_literal: true

# @abstract Rest::Parsers::Xml is a wrapper class for the REXML library.
#   It allows for DOM parsing of XML using XPath selectors.
#
#   XPath References:
#   https://devhints.io/xpath
#   https://www.w3.org/TR/2017/REC-xpath-31-20170321/#id-path-expressions
#
#   REXML References:
#   http://www.germane-software.com/software/rexml/docs/tutorial.html

# @example Return the first "Bar" element.
#   xml = "<Foo attributefoo=\"valuefoo\"><Bar attributebar=\"valuebar\">BarContent</Bar></Foo>"
#   parsed = Rest::Parsers::Xml.new(xml)
#   element = parsed.first("//Bar")
#     => <Bar attributebar='valuebar'> ... </>
#
# @example Return the name and value of the first attribute of the first "Bar" element.
#   ... (continuing previous example) ...
#   element.attributes.first
#     => ["attributebar", "valuebar"]
#
# @author Dan Wichman-Buescher <dan@growpath.com>

require "rexml/document"

module Rest
  module Parsers
    class Xml
      # @param xml_to_parse [String, IO, REXML::Document] The XML to be parsed.
      def initialize(xml_to_parse)
        @xml_to_parse = xml_to_parse
      end

      # Enumerates over all matched objects.
      # @param xpath_selector [String] The XPath selector that will query the XML.
      # @return [Array<REXML::Document>]
      def each(xpath_selector = nil)
        REXML::XPath.each(parsed_document, xpath_selector) do |matched|
          yield(matched) if block_given?
        end
      end

      # @param (see #each)
      # @return [REXML::Document] The first object to match the XPath selector.
      def first(xpath_selector)
        REXML::XPath.first(parsed_document, xpath_selector)
      end

      # @param (see #each)
      # @return [Array<REXML::Document>] All objects that match the XPath selector.
      def match(xpath_selector)
        REXML::XPath.match(parsed_document, xpath_selector)
      end

      private

      attr_reader :xml_to_parse

      def parsed_document
        @parsed_document ||= REXML::Document.new(xml_to_parse)
      rescue StandardError => e
        Rails.logger.error("XML parse failure: #{e.message}")
        raise Rest::Http::ResponseBodyError, e.message
      end
    end
  end
end
