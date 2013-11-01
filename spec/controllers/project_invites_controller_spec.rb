require 'spec_helper'

describe ProjectInvitesController do
  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  let(:other_organisation) { FactoryGirl.create(:organisation) }

  let(:project)  { FactoryGirl.create(:project, name: "Prism") }
  
  before :each do
    invitor = FactoryGirl.create(:organisation, name: "NSA")
    project_membership = FactoryGirl.create(:project_membership, project: project.uri, organisation: invitor.uri)
    project_invite = FactoryGirl.create(:project_invite, project_uri: project.uri.to_s, invitor_organisation_uri: invitor.uri.to_s, invited_organisation_uri: organisation.uri.to_s)
    
    sign_in :user, user
  end

  context do 
    before :each do
      @other_invite = FactoryGirl.create(:project_invite, invited_organisation_uri: other_organisation.uri.to_s)
    end
    
    describe '#reject' do 
      it 'is protected from malicious attacks' do
        put :reject, id: @other_invite.id
        flash.alert.should be_present
        response.should redirect_to :dashboard
      end
    end

    describe '#accept' do 
      it 'is protected from malicious attacks' do
        put :delegate, id: @other_invite.id
        flash.alert.should be_present
        response.should redirect_to :dashboard
      end
    end

    describe '#reject' do 
      it 'is protected from malicious attacks' do
        put :accept, id: @other_invite.id
        flash.alert.should be_present
        response.should redirect_to :dashboard
      end
    end
  end
end
