# -*- coding: utf-8 -*-
require 'spec_helper'

describe ProjectInvitePresenter do

  context "#valid" do
    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_new_organisation) }
  end

  context "#new organisation" do
    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_new_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.should be_valid
    end

    it 'must save' do
      project_invite_presenter.save.should be_true
    end
    
    describe ".new_organisation?" do
      let(:pip) { pip = ProjectInvitePresenter.new }
      
      it "should default to true" do
        pip.new_organisation?.should be_true
      end

      it "should be true if the uri is initialised to nil" do
        pip.invited_organisation_uri = nil
        pip.new_organisation?.should be_true
      end
      
      it "returns true when initialised with a blank uri" do
        pip.invited_organisation_uri = ""
        pip.should be_new_organisation
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

    describe "invitor_organisation_uri" do
      it "should be setable from constructor" do
        pip = ProjectInvitePresenter.new invitor_organisation_uri: 'http://example.org/1'
        pip.invitor_organisation_uri.should == 'http://example.org/1'
      end

      it 'should be mass assignable via #attributes' do
        pip = ProjectInvitePresenter.new
        pip.attributes = {:invitor_organisation_uri => 'http://example.org/1'}
        pip.invitor_organisation_uri.should == 'http://example.org/1'
      end
    end

    describe "#user" do

      context "the user already exists" do
        let!(:user) {
          u = FactoryGirl.build(:user)
          u.email = project_invite_presenter.user_email
          u.save!
          u
        }

        it "should return the existing user" do
          project_invite_presenter.user.should == user
        end
      end

      context "the user doesn't exist" do
        it "should instantiate a (unsaved) user" do
          project_invite_presenter.user.new_record?.should be_true
        end
      end
    end

    describe "#organisation_membership" do
      let!(:om) { project_invite_presenter.organisation_membership }

      it "should instantiate a new Org Membership for the user and org" do
        om.new_record?.should be_true
        om.user.email.should == project_invite_presenter.user_email
        om.organisation_uri.should == project_invite_presenter.invited_organisation.uri.to_s
      end
    end

    describe "#save" do

      it "must create an organisation with the correct details" do
        project_invite_presenter.save
        project_invite_presenter.invited_organisation.should be_persisted
        project_invite_presenter.invited_organisation.name.should == project_invite_presenter.invited_organisation_name
      end

      context "user doesn't already exist" do

        it "must create a user with the correct details" do
          User.any_instance.should_receive(:save).and_call_original
          project_invite_presenter.save
          project_invite_presenter.user.should be_persisted
          project_invite_presenter.user.first_name.should == project_invite_presenter.user_first_name
          project_invite_presenter.user.email.should      == project_invite_presenter.user_email
        end
      end

      context "user already exists" do

        let!(:user) {
          u = FactoryGirl.build(:user)
          u.email = project_invite_presenter.user_email
          u.save!
          u
        }
        it "must use the existing user" do
          User.any_instance.should_not_receive(:save)
          project_invite_presenter.save
          project_invite_presenter.user.should be_persisted
          project_invite_presenter.user.email.should      == project_invite_presenter.user_email
        end
      end

      # TODO.
      it "should send an email"

      it "should create an invite with the right details" do
        project_invite_presenter.save
        pi = project_invite_presenter.project_invite

        pi.should be_persisted
        pi.invited_organisation_uri.should_not be_nil
        pi.invited_organisation_uri.should == project_invite_presenter.invited_organisation.uri
        pi.invitor_organisation_uri.should == project_invite_presenter.invitor_organisation_uri
        pi.project_uri.should == project_invite_presenter.project_uri
      end

      it "should create an org membership for the user" do
        project_invite_presenter.save
        organisation_membership = project_invite_presenter.organisation_membership
        organisation_membership.should be_persisted
        organisation_membership.organisation_uri.should == project_invite_presenter.invited_organisation.uri.to_s
        organisation_membership.user.should == project_invite_presenter.user
      end

    end
  end

  context "existing organisation" do
    let(:project_invite_presenter) { FactoryGirl.build(:project_invite_presenter_for_existing_organisation) }

    it "must have a valid factory" do
      project_invite_presenter.valid?
      Rails.logger.info project_invite_presenter.errors.messages.inspect
      project_invite_presenter.should be_valid
    end

    describe "#new_organisation?" do
      it "should return false" do
        project_invite_presenter.new_organisation?.should be_false
      end
    end

    describe "#invited_organisation" do
      it "should return the existing org" do
        project_invite_presenter.invited_organisation.new_record.should be_false
      end
    end

    describe "#user" do
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

    describe "#organisation_membership" do
      let!(:om) { project_invite_presenter.organisation_membership }

      it "should return nil" do
        om.should be_nil
      end
    end

    describe "#save" do
      it "should create an invite with the right details" do
        project_invite_presenter.save
        project_invite_presenter.project_invite.should be_persisted
        project_invite_presenter.project_invite.invited_organisation_uri.should == project_invite_presenter.invited_organisation_uri
        project_invite_presenter.project_invite.invitor_organisation_uri.should == project_invite_presenter.invitor_organisation_uri
        project_invite_presenter.project_invite.project_uri.should == project_invite_presenter.project_uri
      end
    end

  end

end
