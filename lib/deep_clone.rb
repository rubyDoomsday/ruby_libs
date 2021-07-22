# frozen_string_literal: true

# DeepClone is a lightweight library to assist copying attributes and
# asssociations from the provided record.
# example:
#  record = Record.find(id)
#  attrib = DeepClone.attributes_for(record, ignore: [:name], associations: [:case_status_ids])
#  Record.new(attrib)
class DeepClone
  AUTO_IGNORE = %i[created_by_id updated_by_id created_at updated_at id].freeze

  # @param record [ActiveRecord::ApplicationRecord] The record to copy
  # @param ignore [Array<Symbol>] Shallow fields that you wish to ignore from the copy
  # @param associations [Array<Symbol>] Additional associations that you wish to copy
  def self.attributes_for(record, ignore: [], associations: [])
    return {} unless record.present? && record.is_a?(ApplicationRecord)

    new(record, ignore, associations).send(:attributes)
  end

  def initialize(record, ignore, associations)
    @record       = record
    @ignore       = ignore
    @associations = associations
  end

  private

  def attributes
    shallow_attributes.merge(deep_associations)
  end

  def shallow_attributes
    @record.attributes.deep_symbolize_keys.except(*@ignore + AUTO_IGNORE)
  end

  def deep_associations
    @associations.map do |association|
      value = @record.send(association) if @record.respond_to?(association)
      [association, value]
    end.to_h.compact
  end
end
