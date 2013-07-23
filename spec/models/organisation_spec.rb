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
      subject.name.should == @organisation.name
      subject.lat.should  == @organisation.lat
      subject.lng.should  == @organisation.lng
    end

  end

end
