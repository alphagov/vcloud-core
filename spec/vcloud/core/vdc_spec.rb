require 'spec_helper'

describe Vcloud::Core::Vdc do

  before(:each) do
    @vdc_id = '12345678-1234-1234-1234-000000111232'
    @mock_fog_interface = StubFogInterface.new
    allow(Vcloud::Core::Fog::ServiceInterface).to receive(:new).and_return(@mock_fog_interface)
  end

  context "Class public interface" do
    it { expect(Vcloud::Core::Vdc).to respond_to(:get_by_name) }
  end

  context "Instance public interface" do
    subject { Vcloud::Core::Vdc.new(@vdc_id) }
    it { should respond_to(:id) }
    it { should respond_to(:name) }
    it { should respond_to(:href) }
  end

  context "#initialize" do

    it "should be constructable from just an id reference" do
      obj = Vcloud::Core::Vdc.new(@vdc_id)
      expect(obj.class).to be(Vcloud::Core::Vdc)
    end

    it "should store the id specified" do
      obj = Vcloud::Core::Vdc.new(@vdc_id)
      expect(obj.id).to eq(@vdc_id)
    end

    it "should raise error if id is not in correct format" do
      bogus_id = '123123-bogus-id-123445'
      expect{ Vcloud::Core::Vdc.new(bogus_id) }.to raise_error("vdc id : #{bogus_id} is not in correct format" )
    end

  end

  context "#get_by_name" do

    it "should return a Vcloud::Core::Vdc object if name exists" do
      q_results = [
        { :name => 'vdc-test-1', :href => @vdc_id }
      ]
      mock_query = double(:query_runner)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with('orgVdc', :filter => "name==vdc-test-1").and_return(q_results)
      obj = Vcloud::Core::Vdc.get_by_name('vdc-test-1')
      expect(obj.class).to be(Vcloud::Core::Vdc)
    end

    it "should raise an error if no vDC with that name exists" do
      q_results = [ ]
      mock_query = double(:query_runner)
      expect(Vcloud::Core::QueryRunner).to receive(:new).and_return(mock_query)
      expect(mock_query).to receive(:run).with('orgVdc', :filter => "name==vdc-test-1").and_return(q_results)
      expect{ Vcloud::Core::Vdc.get_by_name('vdc-test-1') }.to raise_exception(RuntimeError, "vDc vdc-test-1 not found")
    end

  end

end
