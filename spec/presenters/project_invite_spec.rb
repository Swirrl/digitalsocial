require 'spec_helper'

describe ProjectInvite do

  context "new organisation" do

    let(:project_invite) { FactoryGirl.build(:project_invite_for_new_organisation) }

    it "must have a valid factory" do
      project_invite.should be_valid
    end

    it "must have a unique email address" do
      FactoryGirl.create(:user, email: 'test@test.com')

      project_invite.user_email = 'test@test.com'
      project_invite.should_not be_valid
    end

    describe ".save" do

      before do
        project_invite.save
      end

      it "must create an organisation with the correct details" do
        project_invite.organisation.should be_persisted
        project_invite.organisation.name.should == project_invite.organisation_name
      end

      it "must create a user with the correct details" do
        project_invite.user.should be_persisted
        project_invite.user.first_name.should == project_invite.user_first_name
        project_invite.user.email.should      == project_invite.user_email
      end

      it "must create an organisation membership with the correct details" do
        project_invite.organisation_membership.should be_persisted
        project_invite.organisation_membership.organisation_uri.should == project_invite.organisation.uri.to_s
        project_invite.organisation_membership.user.should == project_invite.user
        project_invite.organisation_membership.owner.should be_true
      end

      it "must create a request with the correct details" do
        project_invite.request.should be_persisted
        project_invite.request.requestor.should == project_invite.organisation
        project_invite.request.requestable.should == project_invite.project
        project_invite.request.is_invite.should be_true
        project_invite.request.data[:project_membership_nature_uri].should == project_invite.nature_uri
      end

    end

  end

  context "existing organisation" do

    let(:project_invite) { FactoryGirl.build(:project_invite_for_existing_organisation) }

    it "must have a valid factory" do
      project_invite.should be_valid
    end

    describe ".save" do

      before do
        project_invite.save
      end

      it "must create a request with the correct details" do
        project_invite.request.should be_persisted
        project_invite.request.requestor.should == project_invite.organisation
        project_invite.request.requestable.should == project_invite.project
        project_invite.request.is_invite.should be_true
        project_invite.request.data[:project_membership_nature_uri].should == project_invite.nature_uri
      end

    end

  end

end