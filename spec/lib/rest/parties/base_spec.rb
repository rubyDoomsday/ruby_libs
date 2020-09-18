# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rest::Party::Base do
  describe "with config" do
    let(:subject) { described_class.new }

    before(:each) do
      Rest::Party::Base.configure do |c|
        c.host      = "http://host.com"
        c.client_id = "account-id"
        c.token     = "auth-token"
      end
    end

    it "has a config" do
      expect(subject.config).to be_kind_of(Rest::Party::Config)
      expect(subject.config.host).to eq "http://host.com"
      expect(subject.config.client_id).to eq "account-id"
      expect(subject.config.token).to eq "auth-token"
    end

    it "has a client" do
      expect(subject.client).to be_kind_of Rest::Http::Client
    end
  end

  describe "without config" do
    let(:subject) { described_class.new(Rest::Party::Config.new) }

    it "has a config" do
      expect(subject.config).to be_kind_of(Rest::Party::Config)
    end

    it "has a client" do
      expect(subject.client.host).to eq nil
    end
  end
end
