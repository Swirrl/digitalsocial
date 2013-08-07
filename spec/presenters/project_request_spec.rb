require 'spec_helper'

describe ProjectRequest do

  let(:project_request) { FactoryGirl.build(:project_request) }

  it "must have a valid factory" do
    project_request.should be_valid
  end

  it "must have not be for an organisation already a member of the project" do
    FactoryGirl.create(:project_membership, organisation: project_request.sender.organisation_resource.uri.to_s, project: project_request.project.uri.to_s)

    project_request.should_not be_valid
  end

  describe '.save' do

    before do
      project_request.save
    end

    it "must create a request with the correct details" do
      project_request.request.should be_persisted
      project_request.request.sender.should == project_request.sender
      project_request.request.receiver.should == project_request.creator_organisation_owner_membership
      project_request.request.requestable.should == project_request.project
      project_request.request.request_type.should == 'project_request'
      project_request.request.data[:project_membership_nature_uri].should == project_request.nature_uri
    end

  end

end