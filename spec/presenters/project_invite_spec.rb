require 'spec_helper'

describe ProjectInvitePresenter do

  context "new organisation" do
    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_new_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.should be_valid
    end

    describe ".new_organisation?" do
      it "should return true" do
        project_invite_presenter.new_organisation?.should be_true
      end
    end

    describe "invited_organisation" do
      it "should return the new org" do
        project_invite_presenter.invited_organisation.new_record?.should be_true
      end

      it "should have the name set on the presenter" do
        project_invite_presenter.invited_organisation.name.should == project_invite_presenter.invited_organisation_name
      end
    end

    describe "user" do

      context "the user already exists" do
        let!(:user) {
          u = FactoryGirl.build(:user)
          u.email = project_invite_presenter.user_email
          u
        }

        it "should return the existing user" do
          project_invite_presenter.user.should == user
        end
      end

      context "the usser doesn't exist" do
        it "should instantiate a (unsaved) user" do
          project_invite_presenter.user.new_record?.should be_true
        end
      end
    end
  end

  context "existing organisation" do
    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_existing_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.should be_valid
    end

    describe ".new_organisation?" do
      it "should return false" do
        project_invite_presenter.new_organisation?.should be_false
      end
    end

    describe "invited_organisation" do
      it "should return the existing org" do
        project_invite_presenter.invited_organisation.new_record.should be_false
      end
    end

    describe "user" do
      it "should return nil" do
        project_invite_presenter.user.should be_nil
      end
    end

    context "when an open invite already exists" do

      before do
        p = ProjectInvite.new
        p.project_uri = project_invite_presenter.project_uri
        p.invited_organisation_uri = project_invite_presenter.invited_organisation_uri
        p.save!
      end

      it "should not be valid" do
        project_invite_presenter.should_not be_valid
      end

      it "should have an error message about already being invited" do
        project_invite_presenter.valid?
        project_invite_presenter.errors[:project_uri].should include("Someone has invited this organisation to this project")
      end
    end

    context "when organisation is already a member of the project" do
      before do
        pm = ProjectMembership.new
        pm.nature = Concepts::ProjectMembershipNature.all.first.uri
        pm.project = project_invite_presenter.project_uri
        pm.organisation = project_invite_presenter.invited_organisation_uri
        pm.save!
      end

      it "should not be valid" do
        project_invite_presenter.should_not be_valid
      end

      it "should have an error message about the org already being a member" do
        project_invite_presenter.valid?
        project_invite_presenter.errors[:project_uri].should include("Your organisation is already a member of this project")
      end
    end

  end

  # context "new organisation" do

  #   let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_new_organisation) }

  #   it "must have a valid factory" do
  #     project_invite_presenter.should be_valid
  #   end

  #   it "must have a unique email address" do
  #     FactoryGirl.create(:user, email: 'test@test.com')

  #     project_invite_presenter.user_email = 'test@test.com'
  #     project_invite_presenter.should_not be_valid
  #   end

  #   describe ".save" do

  #     before do
  #       project_invite_presenter.save
  #     end

  #     it "must create an organisation with the correct details" do
  #       project_invite_presenter.organisation.should be_persisted
  #       project_invite_presenter.organisation.name.should == project_invite_presenter.organisation_name
  #     end

  #     it "must create a user with the correct details" do
  #       project_invite_presenter.user.should be_persisted
  #       project_invite_presenter.user.first_name.should == project_invite_presenter.user_first_name
  #       project_invite_presenter.user.email.should      == project_invite_presenter.user_email
  #     end

  #     it "must create an organisation membership with the correct details" do
  #       project_invite_presenter.organisation_membership.should be_persisted
  #       project_invite_presenter.organisation_membership.organisation_uri.should == project_invite_presenter.organisation.uri.to_s
  #       project_invite_presenter.organisation_membership.user.should == project_invite_presenter.user
  #       project_invite_presenter.organisation_membership.owner.should be_true
  #     end

  #     it "must create a request with the correct details" do
  #       project_invite_presenter.project_request.should be_persisted
  #       project_invite_presenter.project_request.requestor.should == project_invite_presenter.organisation
  #       project_invite_presenter.project_request.requestable.should == project_invite_presenter.project
  #       project_invite_presenter.project_request.is_invite.should be_true
  #       project_invite_presenter.project_request.project_membership_nature_uri.should == project_invite_presenter.nature_uri
  #     end

  #   end

  # end

  # context "existing organisation" do

  #   let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_existing_organisation) }

  #   it "must have a valid factory" do
  #     project_invite_presenter.should be_valid
  #   end

  #   describe ".save" do

  #     context "without user details" do

  #       before do
  #         project_invite_presenter.save
  #       end

  #       it "must create a request with the correct details" do
  #         project_invite_presenter.project_request.should be_persisted
  #         project_invite_presenter.project_request.requestor.should == project_invite_presenter.organisation
  #         project_invite_presenter.project_request.requestable.should == project_invite_presenter.project
  #         project_invite_presenter.project_request.is_invite.should be_true
  #         project_invite_presenter.project_request.project_membership_nature_uri.should == project_invite_presenter.nature_uri
  #       end

  #       it "must not create a user request if they are not provided" do
  #         project_invite_presenter.user_request.should_not be_persisted
  #       end

  #     end

  #     context "with user details" do

  #       before do
  #         project_invite_presenter.user_first_name = "Foo"
  #         project_invite_presenter.user_email = "foo@bar.com"
  #         project_invite_presenter.save
  #       end

  #       it "must create a user request with the correct details if they are provided" do
  #         project_invite_presenter.user_request.should be_persisted
  #         project_invite_presenter.user_request.user_first_name.should == "Foo"
  #         project_invite_presenter.user_request.user_email.should == "foo@bar.com"
  #       end

  #     end

  #   end

  # end

end