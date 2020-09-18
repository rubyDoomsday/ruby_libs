# frozen_string_literal: true

# PhoneType provides serialization for phone numbers to be stored in the
# database as a string but accessed as a PhoneNumber type.
# @see: lib/phone_number.rb
class PhoneType < ActiveRecord::Type::String
  def initialize(format: :mobile_format)
    @format = format
  end

  def serialize(value)
    if phone = PhoneNumber.new(value)
      super(phone.send(@format))
    end
  rescue PhoneNumber::FormatError
    super(value)
  end

  def deserialize(value)
    PhoneNumber.new(value) unless value.nil?
  end
end

ActiveRecord::Type.register(:phone_type, PhoneType)
