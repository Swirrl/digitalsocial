require 'spec_helper'

feature 'Approving a project request' do

  context 'as an owner' do

    let(:user) { FactoryGirl.create(:user_with_organisations, owner: true, organisations_count: 1) }

    background do
      login_as user, scope: :user
      pm = FactoryGirl.create(:project_membership, organisation: user.organisation_resources.first.uri.to_s)
      FactoryGirl.create(:project_request_presenter, project_uri: pm.project.to_s)
    end

    scenario 'Accepting a project request' do
      visit projects_path
      click_button 'Accept'

      page.should have_content 'request has been accepted'
    end

    scenario 'Rejecting a project request' do
      visit projects_path
      click_button 'Reject'

      page.should have_content 'request has been rejected'
    end

  end
  
  context 'as a non-owner' do

    let(:user) { FactoryGirl.create(:user_with_organisations, owner: false, organisations_count: 1) }

    background do
      login_as user, scope: :user
      pm = FactoryGirl.create(:project_membership, organisation: user.organisation_resources.first.uri.to_s)
      FactoryGirl.create(:project_request_presenter, project_uri: pm.project.to_s)
    end

    scenario 'Accepting a project request' do
      visit projects_path
      click_button 'Accept'

      page.should have_content 'request has been accepted'
    end

    scenario 'Rejecting a project request' do
      visit projects_path
      click_button 'Reject'

      page.should have_content 'request has been rejected'
    end

  end

end