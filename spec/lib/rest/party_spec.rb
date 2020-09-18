# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Party::Config do
  let(:opts) do
    {
      host:           "http://host.ca",
      another_option: "something-custom"
    }
  end

  let(:subject) { described_class.new(opts) }

  it "is configured" do
    expect(subject.configured?).to eq true
  end

  it "has a host" do
    expect(subject.host).to match(/host/)
  end

  it "permits custom options" do
    expect(subject.options.keys).to eq [:another_option]
  end
end
