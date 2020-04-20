# frozen_string_literal: true

# PhoneNumberValidator leverages PhoneNumber to ensure the input for the field
# is a valid phone number. The Validator accepts an option to ensure that the
# provided data can be serialized into a specific format or stores it as a
# default format
# @see: lib/phone_number.rb
#
# @example:
#  model Phone < ApplicationRecord
#    FORMAT = :npa_format
#
#    validates :office_phone_number, phone_number: { format: FORMAT }
#  end
class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    return true if PhoneNumber.new(value).send(options[:format] || :mobile_format)
  rescue PhoneNumber::FormatError => e
    record.errors.add(attribute, options[:message] || e.message)
  end
end
