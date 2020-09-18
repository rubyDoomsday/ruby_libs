# frozen_string_literal: true

# PhoneNumberValidator is a custom Active record validator that ensures that the
# primative string provided in a form field is parseable to a phone_number type.
# @see /lib/phone_number.rb
class PhoneNumberValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return unless value.present?

    return true if PhoneNumber.new(value).send(options[:format] || :mobile_format)
  rescue PhoneNumber::FormatError => e
    record.errors.add(attribute, options[:message] || e.message)
  end
end
