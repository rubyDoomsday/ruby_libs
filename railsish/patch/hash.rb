# frozen_string_literal: true

class Hash
  def blank?
    empty?
  end

  def present?
    !empty?
  end

  def to_param(namespace = nil)
    query = collect do |key, value|
      "#{key}=#{value}"
    end.compact

    query.sort! unless namespace.to_s.include?("[]")
    query.join("&")
  end

  def to_xml
    to_s
  end
end
