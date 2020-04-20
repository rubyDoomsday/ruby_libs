# frozen_string_literal: true

# PhoneType provides serialization for phone numbers to be stored in a database
# as a string and access as a PhoneNumber. It takes an optional parameter to
# store the value in a formatted string that is relevant to the models use
# case.
# @see: lib/phone_number.rb
#
# @example:
#  model Phone < ApplicationRecord
#    FORMAT = :npa_format
#
#    attribute :office_phone_number, :phone_type, format: FORMAT
#  end
class PhoneType < ActiveRecord::Type::String
  def initialize(format: :mobile_format)
    @format = format
  end

  def serialize(value)
    if (phone = PhoneNumber.new(value))
      super(phone.send(@format))
    end
  rescue StandardError
    super(value)
  end

  def deserialize(value)
    PhoneNumber.new(value) unless value.nil?
  end
end

ActiveRecord::Type.register(:phone_type, PhoneType)
