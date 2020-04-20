# frozen_string_literal: true

require "rails_helper"

RSpec.describe PhoneNumber do
  context "instance" do
    let(:primitive) { "1 (199)123-4444" }
    let(:subject) { described_class.new(primitive) }

    it "responds to :to_s" do
      expect(subject.to_s).to eq primitive
      expect("#{subject}").to eq primitive # rubocop:disable Style/RedundantInterpolation
    end

    it "has a country code" do
      expect(subject.c).to eq "1"
      expect(subject.country_code).to eq "1"
    end

    it "has an area code" do
      expect(subject.npa).to eq "199"
      expect(subject.area_code).to eq "199"
    end

    it "has a prefix" do
      expect(subject.nxx).to eq "123"
      expect(subject.prefix).to eq "123"
    end

    it "has a subscriber" do
      expect(subject.xxxx).to eq "4444"
      expect(subject.subscriber).to eq "4444"
    end
  end

  describe "errors" do
    it "raises an error if the primitive is too short" do
      expect { described_class.new("333") }.to raise_error(PhoneNumber::FormatError)
    end

    it "raises an error if the primitive is too long" do
      expect { described_class.new("133344455558") }.to raise_error(PhoneNumber::FormatError)
    end

    it "raises an error if the phone number includes text" do
      expect { described_class.new("919-867-TEXT") }.to raise_error(PhoneNumber::FormatError)
    end

    it "raises an error if the phone number includes extension" do
      expect { described_class.new("919-867-5309 x555") }.to raise_error(PhoneNumber::FormatError)
    end
  end

  context "#nanp_format" do
    it "raises error if insufficient primitive provided" do
      subject = described_class.new("333 4444")
      expect { subject.nanp_format }.to raise_error(PhoneNumber::FormatError)
    end

    it "formats a phone number" do
      subject = described_class.new("999 333 4444")
      expect(subject.nanp_format).to eq "+1-999-333-4444"
    end
  end

  context "#npa_format" do
    it "raises error if insufficient primitive provided" do
      subject = described_class.new("333 4444")
      expect { subject.npa_format }.to raise_error(PhoneNumber::FormatError)
    end

    it "formats a phone number" do
      subject = described_class.new("999 333 4444")
      expect(subject.npa_format).to eq "1 (999) 333-4444"
    end
  end

  context "#mobile_format" do
    it "raises error if insufficient primitive provided" do
      subject = described_class.new("333 4444")
      expect { subject.mobile_format }.to raise_error(PhoneNumber::FormatError)
    end

    it "formats a phone number" do
      subject = described_class.new("999 333 4444")
      expect(subject.mobile_format).to eq "+19993334444"
    end
  end

  context "#strfphone" do
    describe "without area code" do
      it "raises format error when using invalid foramtter" do
        subject = described_class.new("333-4444")
        expect { subject.strfphone("%NPA") }.to raise_error(PhoneNumber::FormatError)
      end

      it "returns phone number with valid formatter" do
        subject = described_class.new("3334444")
        expect { subject.strfphone("%NXX-%XXXX") }.to_not raise_error
      end
    end
  end

  context "normalizes phone numbers" do
    describe "with area code" do
      [
        "1 (999)333-1444",
        "1,999,333,1444",
        "1 999 333.1444",
        "1 999 333 1444",
        "999 333 1444",
        "19993331444",
        "9993331444",
        "9993331444",
      ].each do |primitive|
        it "#{primitive} can format to nanp_format" do
          subject = described_class.new(primitive)

          expect { subject.nanp_format }.to_not raise_error
          expect { subject.npa_format }.to_not raise_error
          expect { subject.mobile_format }.to_not raise_error

          expect(subject.c).to eq "1"
          expect(subject.npa).to eq "999"
          expect(subject.nxx).to eq "333"
          expect(subject.xxxx).to eq "1444"
        end
      end
    end
  end
end
