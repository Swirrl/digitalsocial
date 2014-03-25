require 'spec_helper'

describe ProjectInvitesController do
  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  let(:other_organisation) { FactoryGirl.create(:organisation) }
  let(:project)  { FactoryGirl.create(:project, name: "Prism") }
  let(:invitor) { FactoryGirl.create(:organisation, name: "NSA") }
  let(:project_memmbership) { FactoryGirl.create(:project_membership, project: project.uri, organisation: invitor.uri) }
  let(:project_invite) { FactoryGirl.create(:project_invite, project_uri: project.uri.to_s, invitor_organisation_uri: invitor.uri.to_s, invited_organisation_uri: organisation.uri.to_s) }
  
  before :each do
    sign_in :user, user
  end

  context 'security' do 
    let(:other_invite) { FactoryGirl.create(:project_invite, invited_organisation_uri: other_organisation.uri.to_s) }
    
    describe '#reject' do 
      it 'is protected from malicious attacks' do
        put :reject, id: other_invite.id
        flash.alert.should be_present
        response.should redirect_to :dashboard
      end
    end

    describe '#invite_via_suggestion' do 
      it 'is protected from malicious attacks' do
        put :invite_via_suggestion, id: other_invite.id
        flash.alert.should be_present
        response.should redirect_to :dashboard
      end
    end

    describe '#accept' do 
      it 'is protected from malicious attacks' do
        put :accept, id: other_invite.id
        flash.alert.should be_present
        response.should redirect_to :dashboard
      end
    end
  end

  context '#invite_via_suggestion' do
    let(:project_invite) { FactoryGirl.create(:project_invite_with_invited_user,
                                               project_uri: project.uri.to_s,
                                               invitor_organisation_uri: invitor.uri.to_s,
                                               invited_organisation_uri: organisation.uri.to_s) }
    
    it 'marks the suggested user as invited' do
      put :invite_via_suggestion, id: project_invite.id
      project_invite.reload
      project_invite.should be_handled_suggested_invite
    end

    it 'sends the invitation email to the suggested user' do
      RequestMailer.should_receive(:invite_via_suggestion).with(anything, project_invite, user)
      put :invite_via_suggestion, id: project_invite.id
    end

    it 'sets a flash success notice' do
      put :invite_via_suggestion, id: project_invite.id
      flash.notice.should be_present
      response.should redirect_to :dashboard
    end

    context 'when inviting a user that has already been invited' do
      
      let(:project_invite) { FactoryGirl.create(:project_invite, project_uri: project.uri.to_s, invitor_organisation_uri: invitor.uri.to_s, invited_organisation_uri: organisation.uri.to_s, invited_email: user.email) }

      it 'sets the project_invite to not be a handled_invite' do 
        put :invite_via_suggestion, id: project_invite.id
        project_invite.reload
        project_invite.should be_handled_suggested_invite
      end

      it 'displays a notification' do 
        put :invite_via_suggestion, id: project_invite.id
        flash.notice.should be_present
      end
    end
  end

  context '#reject_suggestion' do
    it 'should mark the suggestion as handled' do 
      put :reject_suggestion, id: project_invite.id
      project_invite.reload
      project_invite.should be_handled_suggested_invite
    end
  end
  
end
