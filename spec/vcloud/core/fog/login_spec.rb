require 'spec_helper'
require 'stringio'

describe Vcloud::Core::Fog::Login do
  describe "#token" do
    it "should return the output from get_token" do
      expect(subject).to receive(:get_token).and_return('mekmitasdigoat')
      expect(subject.token('supersekret')).to eq("mekmitasdigoat")
    end
  end

  describe "#token_export" do
    context "when called from a POSIX shell" do
      it "should call #token with pass arg and returns POSIX shell export string" do
        expect(subject).to receive(:`).with('ps -p $$ -o ucomm=').and_return('bash')
        expect(subject).to receive(:token).with('supersekret').and_return('mekmitasdigoat')
        expect(subject.token_export("supersekret")).to eq("export FOG_VCLOUD_TOKEN=mekmitasdigoat")
      end
    end

    context "when called from a fish shell" do
      it "should call #token with pass arg and returns fish shell export string" do
        expect(subject).to receive(:`).with('ps -p $$ -o ucomm=').and_return('fish')
        expect(subject).to receive(:token).with('supersekret').and_return('mekmitasdigoat')
        expect(subject.token_export("supersekret")).to eq("set -x FOG_VCLOUD_TOKEN mekmitasdigoat")
      end
    end
  end

  describe "#check_plaintext_pass" do
    context "vcloud_director_password not set" do
      it "should not raise an exception" do
        expect(Vcloud::Core::Fog).to receive(:fog_credentials_pass).and_return(nil)
        expect(subject).to receive(:get_token)
        expect { subject.token('supersekret') }.not_to raise_error
      end
    end

    context "vcloud_director_password empty string" do
      it "should not raise an exception" do
        expect(Vcloud::Core::Fog).to receive(:fog_credentials_pass).and_return('')
        expect(subject).to receive(:get_token)
        expect { subject.token('supersekret') }.not_to raise_error
      end
    end

    context "vcloud_director_password non-empty string" do
      it "should raise an exception" do
        expect(Vcloud::Core::Fog).to receive(:fog_credentials_pass).and_return('supersekret')
        expect(subject).to_not receive(:get_token)
        expect { subject.token('supersekret') }.to raise_error(
          RuntimeError,
          "Found plaintext vcloud_director_password entry. Please set it to an empty string as storing passwords in plaintext is insecure. See http://gds-operations.github.io/vcloud-tools/usage/ for further information."
        )
      end
    end
  end
end
