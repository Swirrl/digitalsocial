require 'spec_helper'

describe ProjectRequestPresenter do

  let(:project_request_presenter) { FactoryGirl.build(:project_request_presenter) }
  let(:project) { Project.find(project_request_presenter.project.uri.to_s) }

  it "must have a valid factory" do
    project_request_presenter.should be_valid
  end

  it "must have not be for an organisation already a member of the project" do
    FactoryGirl.create(:project_membership, organisation: project_request_presenter.organisation.uri.to_s, project: project_request_presenter.project.uri.to_s)

    project_request_presenter.should_not be_valid
  end

  describe '.save' do

    context "without user details" do

      before do
        project_request_presenter.save
      end

      it "must create a project request with the correct details" do
        project_request_presenter.project_request.should be_persisted
        project_request_presenter.project_request.requestable.should == project_request_presenter.project
        project_request_presenter.project_request.requestor.should == project_request_presenter.organisation
        project_request_presenter.project_request.project_membership_nature_uri.should == project_request_presenter.nature_uri
      end

    end

    context "with user details" do

      before do
        
      end

      it "must create a user request with the correct details if they are provided" do
        organisation = FactoryGirl.create(:organisation)

        project_request_presenter.user_first_name = "Foo"
        project_request_presenter.user_email = "foo@bar.com"
        project_request_presenter.user_organisation_uri = organisation.uri.to_s
        project_request_presenter.save

        project_request_presenter.user_request.should be_persisted
        project_request_presenter.user_request.user_first_name.should == "Foo"
        project_request_presenter.user_request.user_email.should == "foo@bar.com"
        project_request_presenter.user_request.requestable.should == organisation
      end

    end

  end

end