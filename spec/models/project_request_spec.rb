require 'spec_helper'

describe ProjectRequest do

  let(:organisation) { FactoryGirl.create(:organisation_with_users, users_count: 3) }
  let(:project_request) { FactoryGirl.create(:project_request, requestor_organisation_uri: organisation.uri.to_s) }


  describe "#accept" do

    it "should send an email to the accepted organisation's members" do
      lambda { project_request.accept! }.should change(ActionMailer::Base.deliveries, :count).by(3)
    end

  end

end