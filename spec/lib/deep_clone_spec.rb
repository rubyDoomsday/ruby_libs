# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeepClone do # rubocop:disable Metrics/BlockLength
  let(:record) { Mock.new }

  context ".attributes_for" do
    it "requires a record" do
      empty_record = double("Record")
      allow(empty_record).to receive(:present?).and_return(false)
      attrib = described_class.attributes_for(empty_record)
      expect(attrib).to eq({})
    end

    it "only likes ApplicationRecords" do
      empty_record = double("Record")
      allow(empty_record).to receive(:present?).and_return(true)
      attrib = described_class.attributes_for(empty_record)
      expect(attrib).to eq({})
    end

    it "copies all shallow_attributes" do
      attrib = described_class.attributes_for(record)
      expect(attrib.is_a?(Hash)).to be true
      expect(attrib.keys).to include(:ignored_attrib)
      expect(attrib[:created_by_id]).to eq nil
      expect(attrib[:updated_by_id]).to eq nil
      expect(attrib[:created_at]).to eq nil
      expect(attrib[:updated_at]).to eq nil
      expect(attrib[:ignored_attrib]).to eq "this should be ignored"
      expect(attrib[:association]).to eq nil
    end

    it "copies nested associations" do
      attrib = described_class.attributes_for(record, associations: [:association])
      expect(attrib.is_a?(Hash)).to be true
      expect(attrib.keys).to include(:ignored_attrib, :association)
      expect(attrib[:ignored_attrib]).to eq "this should be ignored"
      expect(attrib[:association]).to_not eq nil
    end

    it "ignores some attributes" do
      attrib = described_class.attributes_for(record, ignore: [:ignored_attrib])
      expect(attrib.is_a?(Hash)).to be true
      expect(attrib.keys).to_not include(:ignored_attrib)
    end
  end

  private

  class ApplicationRecord
    def id
      1001
    end

    def present?
      true
    end
  end

  class Mock < ApplicationRecord
    def attributes
      {
        created_by_id: 1,
        updated_by_id: 1,
        created_at: Time.new(1982, 12, 10).utc,
        updated_at: Time.now.utc,
        ignored_attrib: "this should be ignored",
        association_id: association.id,
      }
    end

    def association
      @association ||= MockAssociation.new
    end
  end

  class MockAssociation < ApplicationRecord
    def attributes
      {
        created_by_id: 1,
        updated_by_id: 1,
        created_at: Time.now.utc - 2.days,
        updated_at: Time.now.utc,
        ignored_attrib: "this should be ignored",
        another_attrib: "hello",
      }
    end
  end

end
