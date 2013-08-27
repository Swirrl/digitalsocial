require 'spec_helper'

describe ProjectRequestPresenter do
  let(:project_request_presenter) { FactoryGirl.build(:project_request_presenter) }

  describe "#project_request" do
    let(:project_request) { project_request_presenter.project_request }

    it "should instantiate a project request based on the params" do
      project_request.new_record?.should be_true
      project_request.requestor_organisation_uri.should == project_request_presenter.requestor_organisation_uri
      project_request.project_uri.should == project_request_presenter.project_uri
    end

  end

  describe "#save" do
    it "should create a request with the right details" do
      project_request_presenter.save
      project_request_presenter.project_request.should be_persisted

      project_request_presenter.project_request.requestor_organisation_uri.should == project_request_presenter.requestor_organisation_uri
      project_request_presenter.project_request.project_uri.should == project_request_presenter.project_uri
    end
  end

  context "when there's an existing pending request" do

    let!(:project_request) { project_request_presenter.project_request.save! }

    it "should be invalid" do
      project_request_presenter.should_not be_valid
    end
    it "should have an error about not having existing requests" do
      project_request_presenter.valid?
      project_request_presenter.errors[:project_uri].should include("Your organisation has already requsted membership to this project")
    end
  end

   context "when organisation is already a member of the project" do
    before do
      pm = ProjectMembership.new
      pm.nature = Concepts::ProjectMembershipNature.all.first.uri
      pm.project = project_request_presenter.project_uri
      pm.organisation = project_request_presenter.requestor_organisation_uri
      pm.save!
    end

    it "should not be valid" do
      project_request_presenter.should_not be_valid
    end

    it "should have an error message about the org already being a member" do
      project_request_presenter.valid?
      project_request_presenter.errors[:project_uri].should include("This organisation is already a member of this project")
    end
  end



  # let(:project_request_presenter) { FactoryGirl.build(:project_request_presenter) }
  # let(:project) { Project.find(project_request_presenter.project.uri.to_s) }

  # it "must have a valid factory" do
  #   project_request_presenter.should be_valid
  # end

  # it "must have not be for an organisation already a member of the project" do
  #   FactoryGirl.create(:project_membership, organisation: project_request_presenter.organisation.uri.to_s, project: project_request_presenter.project.uri.to_s)

  #   project_request_presenter.should_not be_valid
  # end

  # describe '.save' do

  #   context "without user details" do

  #     before do
  #       project_request_presenter.save
  #     end

  #     it "must create a project request with the correct details" do
  #       project_request_presenter.project_request.should be_persisted
  #       project_request_presenter.project_request.requestable.should == project_request_presenter.project
  #       project_request_presenter.project_request.requestor.should == project_request_presenter.organisation
  #       project_request_presenter.project_request.project_membership_nature_uri.should == project_request_presenter.nature_uri
  #     end

  #   end

  #   context "with user details" do

  #     before do

  #     end

  #     it "must create a user request with the correct details if they are provided" do
  #       organisation = FactoryGirl.create(:organisation)

  #       project_request_presenter.user_first_name = "Foo"
  #       project_request_presenter.user_email = "foo@bar.com"
  #       project_request_presenter.user_organisation_uri = organisation.uri.to_s
  #       project_request_presenter.save

  #       project_request_presenter.user_request.should be_persisted
  #       project_request_presenter.user_request.user_first_name.should == "Foo"
  #       project_request_presenter.user_request.user_email.should == "foo@bar.com"
  #       project_request_presenter.user_request.requestable.should == organisation
  #     end

  #   end

  # end

end