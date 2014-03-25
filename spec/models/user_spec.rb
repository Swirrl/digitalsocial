require 'spec_helper'

describe User do

  context 'validations' do

    let(:user) { FactoryGirl.build(:user) }


    it 'must have a valid factory' do
      user.should be_valid
    end

  end

  context 'sending request digests' do

    before(:each) do
      ActionMailer::Base.deliveries = []
    end

    describe '.send_request_digests' do

      context 'one organisation' do

        let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
        let(:other_user) { FactoryGirl.create(:user) }

        let(:organisation) { user.organisation_resources.first }
        let(:other_org) { FactoryGirl.create(:organisation) }
        let(:project) { FactoryGirl.create(:project) }

        it 'should not send any emails if not pending requests' do
          lambda { User.send_request_digests }.should_not change(ActionMailer::Base.deliveries, :count)
        end

        it 'should send an email if a user has pending invites to projects' do
          FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: organisation.uri.to_s, open: true)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should send an email if a user has pending requests' do
          pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
          FactoryGirl.create(:project_request, project_uri: pm.project.to_s, requestor_organisation_uri: other_org.uri.to_s, open: true)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should only send one email if a user has multiple invites or requests' do
          FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: organisation.uri.to_s, open: true)

          pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
          FactoryGirl.create(:project_request, project_uri: pm.project.to_s, requestor_organisation_uri: other_org.uri.to_s, open: true)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should not send an email if the requests have been responded to' do
          pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
          5.times do
            FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: organisation.uri.to_s, open: false, accepted: true)
            FactoryGirl.create(:project_request, project_uri: pm.project.to_s, requestor_organisation_uri: other_org.uri.to_s, open: false, accepted: true)
          end

          lambda { User.send_request_digests }.should_not change(ActionMailer::Base.deliveries, :count)
        end

        it 'should send an email if a user has pending user requests' do
          FactoryGirl.create(:user_request, organisation_uri: organisation.uri.to_s, open: true, user: other_user)

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(1)
        end

        it 'should not send if a user is unsubscribed from notifications' do
          user.update_attribute :receive_notifications, false
          FactoryGirl.create(:user_request, organisation_uri: organisation.uri.to_s, open: true, user: other_user)

          lambda { User.send_request_digests }.should_not change(ActionMailer::Base.deliveries, :count)
        end

        it 'should not send if a user has never signed in' do
          user.update_attribute :sign_in_count, 0
          FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: organisation.uri.to_s, open: true)

          pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
          FactoryGirl.create(:project_request, project_uri: pm.project.to_s, requestor_organisation_uri: other_org.uri.to_s, open: true)

          lambda { User.send_request_digests }.should_not change(ActionMailer::Base.deliveries, :count)
        end

      end

      context 'multiple organisations' do

        let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 3) }
        let(:other_org) { FactoryGirl.create(:organisation) }
        let(:project) { FactoryGirl.create(:project) }

        it 'should send separate emails to the same user if they are part of more than one organisation' do
          user.organisation_resources.each do |o|
            FactoryGirl.create(:project_invite, project_uri: project.uri, invitor_organisation_uri: other_org.uri.to_s, invited_organisation_uri: o.uri.to_s, open: true)
          end

          lambda { User.send_request_digests }.should change(ActionMailer::Base.deliveries, :count).by(3)
        end

      end

    end

  end

  describe '#create_with_organisation_membership_from_project_invite' do
    let(:project_invite) { FactoryGirl.create(:project_invite_with_invited_user) }
    before :each do 
      @user = User.create_with_organisation_membership_from_project_invite(project_invite)
    end

    it 'should create a valid User' do
      @user.should be_valid
    end

    it 'should set a reset password token' do 
      @user.reset_password_token.should_not be_blank
    end

    it 'should record when the reset password token was created' do 
      @user.reset_password_sent_at.should be_present
    end

    it 'should create an organisation membership' do 
      organisation = @user.organisation_resources.first 
      organisation.should == project_invite.invited_organisation_resource      
    end

  end
  
end
