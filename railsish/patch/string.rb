# frozen_string_literal: true

class String
  def present?
    !empty?
  end

  def blank?
    empty?
  end
end
