# frozen_string_literal: true

require 'tzinfo'

class Time
  def self.zone
    OpenStruct.new(
      name: "Eastern Time (US & Canada)",
      tzinfo: ::TZInfo::Timezone.get("America/New_York"),
      utc_offset: nil,
    )
  end
end
