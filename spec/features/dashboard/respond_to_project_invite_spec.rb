require 'spec_helper'

feature 'Respond to project invite' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    project = FactoryGirl.create(:project, name: "Prism")
    invitor = FactoryGirl.create(:organisation, name: "NSA")
    project_membership = FactoryGirl.create(:project_membership, project: project.uri, organisation: invitor.uri)
    project_invite = FactoryGirl.create(:project_invite, project_uri: project.uri.to_s, invitor_organisation_uri: invitor.uri.to_s, invited_organisation_uri: organisation.uri.to_s)

    login_as user, scope: :user
    visit dashboard_path
  end

  scenario 'Should see project invite' do
    page.should have_content "NSA has invited your organisation to join their Prism activity."
  end

  scenario 'Should allow confirmation if nature is specified', js: true do
    click_link 'Accept'
    check 'Sole funder'
    click_button 'Confirm'

    page.should have_content "invite has been accepted"
  end

  scenario 'Should not allow confirmation if nature is not specified', js: true do
    click_link 'Accept'
    click_button 'Confirm'

    page.should_not have_content "invite has been accepted"
  end

  scenario 'Should allow invite to be rejected' do
    click_link 'Ignore'

    page.should_not have_content "NSA has invited you to join Prism"
    page.should_not have_content "invite has been accepted"
  end
end
