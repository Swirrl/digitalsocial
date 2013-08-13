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

    before do
      project_request_presenter.save
    end

    it "must create a request with the correct details" do
      project_request_presenter.request.should be_persisted
      project_request_presenter.request.requestable.should == project_request_presenter.project
      project_request_presenter.request.requestor.should == project_request_presenter.organisation
      project_request_presenter.request.data[:project_membership_nature_uri].should == project_request_presenter.nature_uri
    end

  end

end