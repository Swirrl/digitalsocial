require 'spec_helper'

describe Organisation do
  
  context "syncing tripod organisations" do

    subject do
      @organisation = FactoryGirl.create(:organisation)
      @organisation.tripod_organisation
    end

    it "should create a tripod organisation" do
      subject.should_not be_nil
    end

    it "should create a valid tripod organisation" do
      subject.should be_valid
    end

    it "should created a correct tripod organisation" do
      subject.name.should_not be_blank
      subject.name.should == @organisation.name
      subject.lat.should  == @organisation.lat
      subject.lng.should  == @organisation.lng
    end

    it "should update its tripod organisation" do
      original_name = subject.name
      @organisation.update_attribute :name, "A different organisation name"
      @organisation.tripod_organisation.name.should == @organisation.name
      @organisation.tripod_organisation.name.should_not be_blank
      @organisation.tripod_organisation.name.should_not == original_name
    end

  end

end
