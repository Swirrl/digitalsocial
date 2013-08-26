require 'spec_helper'

feature 'Invite users wizard step' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit organisations_build_invite_users_path
  end

  scenario 'Skipping the invite users step' do
    page.should have_link('Skip', href: organisations_build_new_project_path)
  end

  scenario 'Fill in team member details' do
    pending # Waiting on user request model changes
  end
  
end