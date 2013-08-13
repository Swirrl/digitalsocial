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
        project_invite_presenter.request.should be_persisted
        project_invite_presenter.request.requestor.should == project_invite_presenter.organisation
        project_invite_presenter.request.requestable.should == project_invite_presenter.project
        project_invite_presenter.request.is_invite.should be_true
        project_invite_presenter.request.project_membership_nature_uri.should == project_invite_presenter.nature_uri
      end

    end

  end

  context "existing organisation" do

    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_existing_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.should be_valid
    end

    describe ".save" do

      before do
        project_invite_presenter.save
      end

      it "must create a request with the correct details" do
        project_invite_presenter.request.should be_persisted
        project_invite_presenter.request.requestor.should == project_invite_presenter.organisation
        project_invite_presenter.request.requestable.should == project_invite_presenter.project
        project_invite_presenter.request.is_invite.should be_true
        project_invite_presenter.request.project_membership_nature_uri.should == project_invite_presenter.nature_uri
      end

    end

  end

end