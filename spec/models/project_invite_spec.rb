require 'spec_helper'

describe ProjectInvite do
  context 'without suggested user invite' do
    let(:project_invite) { FactoryGirl.create(:project_invite) }

    it '#suggested_invite? should be true' do
      project_invite.should_not be_suggested_invite
    end

    it 'should be marked as handled' do
      project_invite.should be_handled_suggested_invite
    end
    
  end

  context 'with suggested user invite' do
    let(:project_invite) { FactoryGirl.create(:project_invite_with_invited_user) }

    it '#suggested_invite? should be true' do
      project_invite.should be_suggested_invite
    end

    it 'should not be marked as handled' do
      project_invite.should_not be_handled_suggested_invite
    end
    
    context '#set_handled_suggested_user' do
      it 'should remove suggested user details' do
        project_invite.set_handled_suggested_user!
        project_invite.should be_handled_suggested_invite
      end
      
      it 'should persist changes' do
        project_invite.set_handled_suggested_user!
        project_invite.should be_persisted
      end
    end
  end
end
