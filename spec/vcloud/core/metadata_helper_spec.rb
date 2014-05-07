require 'spec_helper'

module Vcloud
  module Core
    describe MetadataHelper do
      context "get_metadata" do

        it "should process valid metadata types" do
          metadata_entries = [
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => 'role_name',
                  :TypedValue => {
                      :xsi_type => 'MetadataStringValue',
                      :Value => 'james-bond'
                  }},
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => "server_number",
                  :TypedValue => {:xsi_type => "MetadataNumberValue", :Value => "-10"}
              },
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => "created_at",
                  :TypedValue => {:xsi_type => "MetadataDateTimeValue", :Value => "2013-12-16T14:30:05.000Z"}
              },
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => "daily_shutdown",
                  :TypedValue => {:xsi_type => "MetadataBooleanValue", :Value => "false"}
              }
          ]
          metadata = MetadataHelper.extract_metadata(metadata_entries)
          expect(metadata.count).to eq(4)
          expect(metadata[:role_name]).to eq('james-bond')
          expect(metadata[:server_number]).to eq(-10)
          expect(metadata[:created_at]).to eq(DateTime.parse("2013-12-16T14:30:05.000Z"))
          expect(metadata[:daily_shutdown]).to be_false
        end

        it "should skip metadata entry if entry type is not application/vnd.vmware.vcloud.metadata.value+xml" do
          metadata_entries = [
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => 'role_name',
                  :TypedValue => {
                      :xsi_type => 'MetadataStringValue',
                      :Value => 'james-bond'
                  }},
              {
                  :Key => "untyped_key",
                  :TypedValue => {:xsi_type => "MetadataNumberValue", :Value => "-10"}
              },

          ]
          metadata = MetadataHelper.extract_metadata(metadata_entries)
          expect(metadata.count).to eq(1)
          metadata.keys.should_not include :untyped_key
        end

        it "should include unrecognized metadata types" do
          metadata_entries = [
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => 'role_name',
                  :TypedValue => {
                      :xsi_type => 'MetadataStringValue',
                      :Value => 'james-bond'
                  }},
              {
                  :type => Fog::ContentTypes::METADATA,
                  :Key => "unrecognized_type_key",
                  :TypedValue => {:xsi_type => "MetadataWholeNumberValue", :Value => "-10"}
              },

          ]
          metadata = MetadataHelper.extract_metadata(metadata_entries)
          expect(metadata.count).to eq(2)
          metadata.keys.should include :unrecognized_type_key
        end


      end


    end

  end
end
