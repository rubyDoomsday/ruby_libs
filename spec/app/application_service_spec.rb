# frozen_string_literal: true

require "rails_helper"

RSpec.describe ApplicationService do
  class Mock < ApplicationService
    def initialize(name:, value:)
      @name = name
      @value = value
    end

    private

    attr_reader :name, :value

    def call
      result!("#{name} + #{value}")
    end
  end

  let(:subject) { Mock }
  let(:params) { { name: "foo", value: "bar" } }

  it { expect(subject).to be < ApplicationService }

  context ".call" do
    it "returns an application service" do
      service = subject.call(params)
      expect(service).to be_kind_of Mock
      expect(service.success?).to eq true
      expect(service.failure?).to eq false
      expect(service.errors).to be_empty
      expect(service.result).to eq "foo + bar"
      service.success do |result|
        expect(result).to eq "foo + bar"
      end

      allow_any_instance_of(Mock)
        .to receive(:errors)
        .and_return(["something failed"])
      service.failure do |errors|
        expect(errors).to eq ["something failed"]
      end
    end

    it "yields an application service" do
      subject.call(params) do |service|
        expect(service).to be_kind_of Mock
        expect(service.success?).to eq true
        expect(service.failure?).to eq false
        expect(service.errors).to be_empty
        expect(service.result).to eq "foo + bar"

        service.success do |result|
          expect(result).to eq "foo + bar"
        end

        allow_any_instance_of(Mock)
          .to receive(:errors)
          .and_return(["something failed"])
        service.failure do |errors|
          expect(errors).to eq ["something failed"]
        end
      end
    end
  end
end
