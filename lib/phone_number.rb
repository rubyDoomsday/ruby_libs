# frozen_string_literal: true

# Phone numbers stored in GP may include dashes or additional numbers etc.
# This class is provided to ensure that you get back the number(s) you need.
#
# The formatting convention for phone numbers is C-NPA-NXX-XXXX,
#  - C:    Is the single digit country code
#  - NPA:  Is the three digit area code
#  - NXX:  Subscriber prefix for the local central office
#  - XXXX: Is the specific subscriber number
class PhoneNumber
  class FormatError < StandardError; end

  VALID_CHARACTERS = /\A[0-9\(\)\-\s\.\,\+]+\z/.freeze

  FORMATS = [
    NANP_FORMAT   = "+%C-%NPA-%NXX-%XXXX",
    NPA_FORMAT    = "%C (%NPA) %NXX-%XXXX",
    MOBILE_FORMAT = "+%C%NPA%NXX%XXXX",
  ].freeze

  COUNTRY_CODES = [
    USA = "1",
  ].freeze

  attr_reader :country_code, :area_code, :prefix, :subscriber

  alias c country_code
  alias npa area_code
  alias nxx prefix
  alias xxxx subscriber

  # @param primitive [String|Integer] the unformatted phone number
  def initialize(primitive)
    raise FormatError, "invalid format" if !primitive.respond_to?(:to_s) || primitive.length < 7
    raise FormatError, "#{primitive} has invalid characters" unless primitive.match?(VALID_CHARACTERS)

    @primitive = primitive

    @sections = parse_primitive(primitive)
    raise FormatError, "invalid format" if @sections.empty?

    load_instance_vars(@sections.dup)
  end

  # @return [String] The primitive phone number.
  # This will ensure compliance if a PhoneNumber is used during string
  # interpolation throughout the application without interference.
  def to_s
    @primitive
  end

  # Full number separated by hyphens: +C-NPA-NXX-XXXX
  # @return [String] The formatted phone number
  def nanp_format
    strfphone(NANP_FORMAT)
  end

  # Full number with area code in parens: C (NPA) NXX-XXXX
  # @return [String] The formatted phone number
  def npa_format
    strfphone(NPA_FORMAT)
  end

  # Full Number with no division: +CNPANXXXXXX
  # @return [String] The formatted phone number
  def mobile_format
    strfphone(MOBILE_FORMAT)
  end

  # Build a format using portion-keys preceded by a "%" sign. If the portion-key
  # is not present in the primitive number and no defaults are available, then
  # an error is raised.
  # @example: PhoneNumber.new("9196875309").strfphone("%C-%NPA-%NXX-%XXXX")
  #
  # @param formatter [String] The desired format of the phone number
  # @return [String] The interpreted phone number
  def strfphone(formatter)
    flags = formatter.split("%")
    return if flags.empty?

    flags.each_with_object([]) do |f, result|
      next unless (flag = f.match(/(\+|C|NPA|NXX|XXXX)/))

      result << construct(flag)
    end.join
  end

  private

  # parses a primitive phone number string into readable sections
  # @param primitive [String] Raw unformatted phone number string
  # @return [Array<String>] The ordered phone number sections
  def parse_primitive(primitive)
    # ensure string and strip all non-digit characters and whitespace
    raw_string = primitive.to_s.gsub(/(\s|\D)/, "%")
    raw_sections = raw_string.split("%")
    raw_sections.flat_map { |rs| parse_section(rs) }.compact
  end

  # slices up raw section strings into readable units
  # @param raw_section [String] the string to slice
  # @retrun [Array<String|Array>] Dissected phone number string
  def parse_section(raw_section)
    case raw_section.length
    when 11      then [raw_section.slice!(0), parse_section(raw_section)].flatten
    when 7, 10   then [raw_section.slice!(0..2), parse_section(raw_section)].flatten
    when 1, 3, 4 then raw_section
    end
  end

  # helper method to process a provided flag
  # @param flag [MatchData] The match data response from a regex parsing
  # @return [String] The interpreted/modified string
  def construct(flag)
    return "+" if flag.string == "+"

    portion_key = flag.captures.first
    substitution_alias = portion_key.downcase
    flag.string.sub(portion_key, send(substitution_alias))
  rescue TypeError
    case portion_key
    when "NPA" then raise FormatError, "invalid area code"
    when "NXX" then raise FormatError, "invalid prefix"
    when "XXXX" then raise FormatError, "invalid subscriber"
    else raise FormatError, "invalid format"
    end
  end

  def load_instance_vars(sections)
    # processing order is important here
    @country_code = load_country_code(sections)
    @area_code    = load_area_code(sections)
    @prefix       = load_prefix(sections)
    @subscriber   = load_subscriber(sections)
  end

  # C: Is the single digit country code
  def load_country_code(sections)
    # Assumes all phone numbers are USA unless specified
    if COUNTRY_CODES.include?(sections.first)
      sections.shift
    else
      sections.delete(sections.first)
      USA
    end
  end

  # NPA: Is the three digit area code
  def load_area_code(sections)
    return if sections.empty? || sections.first.length < 3

    sections.shift if sections.second.length == 3
  end

  # NXX: Subscriber prefix for the local central office
  def load_prefix(sections)
    return if sections.empty? || sections.first.length < 3

    sections.shift if sections.second.length == 4
  end

  # XXXX: Is the specific subscriber number
  def load_subscriber(sections)
    sections.shift if sections.first&.length == 4
  end
end
