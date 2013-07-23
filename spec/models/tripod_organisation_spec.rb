require 'spec_helper'

describe TripodOrganisation do
  
  subject do
    @organisation = FactoryGirl.create(:organisation)
    @organisation.tripod_organisation
  end

  it "should not respond to private organisation details" do
    subject.should_not respond_to(:email)
    subject.should_not respond_to(:contact_name)
    subject.should_not respond_to(:password)
  end

end
