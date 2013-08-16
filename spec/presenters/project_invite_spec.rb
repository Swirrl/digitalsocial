require 'spec_helper'

describe ProjectInvitePresenter do

  context "new organisation" do

    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_new_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.should be_valid
    end

    it "must have a unique email address" do
      FactoryGirl.create(:user, email: 'test@test.com')

      project_invite_presenter.user_email = 'test@test.com'
      project_invite_presenter.should_not be_valid
    end

    describe ".save" do

      before do
        project_invite_presenter.save
      end

      it "must create an organisation with the correct details" do
        project_invite_presenter.organisation.should be_persisted
        project_invite_presenter.organisation.name.should == project_invite_presenter.organisation_name
      end

      it "must create a user with the correct details" do
        project_invite_presenter.user.should be_persisted
        project_invite_presenter.user.first_name.should == project_invite_presenter.user_first_name
        project_invite_presenter.user.email.should      == project_invite_presenter.user_email
      end

      it "must create an organisation membership with the correct details" do
        project_invite_presenter.organisation_membership.should be_persisted
        project_invite_presenter.organisation_membership.organisation_uri.should == project_invite_presenter.organisation.uri.to_s
        project_invite_presenter.organisation_membership.user.should == project_invite_presenter.user
        project_invite_presenter.organisation_membership.owner.should be_true
      end

      it "must create a request with the correct details" do
        project_invite_presenter.project_request.should be_persisted
        project_invite_presenter.project_request.requestor.should == project_invite_presenter.organisation
        project_invite_presenter.project_request.requestable.should == project_invite_presenter.project
        project_invite_presenter.project_request.is_invite.should be_true
        project_invite_presenter.project_request.project_membership_nature_uri.should == project_invite_presenter.nature_uri
      end

    end

  end

  context "existing organisation" do

    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_existing_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.should be_valid
    end

    describe ".save" do

      context "without user details" do

        before do
          project_invite_presenter.save
        end

        it "must create a request with the correct details" do
          project_invite_presenter.project_request.should be_persisted
          project_invite_presenter.project_request.requestor.should == project_invite_presenter.organisation
          project_invite_presenter.project_request.requestable.should == project_invite_presenter.project
          project_invite_presenter.project_request.is_invite.should be_true
          project_invite_presenter.project_request.project_membership_nature_uri.should == project_invite_presenter.nature_uri
        end

        it "must not create a user request if they are not provided" do
          project_invite_presenter.user_request.should_not be_persisted
        end

      end

      context "with user details" do

        before do
          project_invite_presenter.user_first_name = "Foo"
          project_invite_presenter.user_email = "foo@bar.com"
          project_invite_presenter.save
        end

        it "must create a user request with the correct details if they are provided" do
          project_invite_presenter.user_request.should be_persisted
          project_invite_presenter.user_request.user_first_name.should == "Foo"
          project_invite_presenter.user_request.user_email.should == "foo@bar.com"
        end

      end

    end

  end

end