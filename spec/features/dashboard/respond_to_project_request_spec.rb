require 'spec_helper'

feature 'Respond to project request' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    project = FactoryGirl.create(:project, name: "Prism")
    project_membership = FactoryGirl.create(:project_membership, project: project.uri, organisation: organisation.uri)
    requestor = FactoryGirl.create(:organisation, name: "GCHQ")
    project_request = FactoryGirl.create(:project_request, project_uri: project.uri.to_s, requestor_organisation_uri: requestor.uri.to_s)

    login_as user, scope: :user
    visit user_path
  end

  scenario 'Should see project request' do
    page.should have_content "GCHQ has requested to join Prism"
  end

  scenario 'Should allow confirmation if nature is specified', js: true do
    click_link 'Accept'
    check 'Sole funder'
    click_button 'Confirm'

    page.should have_content "request has been accepted"
  end

  scenario 'Should not allow confirmation if nature is not specified', js: true do
    click_link 'Accept'
    click_button 'Confirm'

    page.should_not have_content "request has been accepted"
  end

  scenario 'Should allow request to be rejected' do
    click_link 'Ignore'

    page.should_not have_content "GCHQ has requested to join Prism"
    page.should_not have_content "request has been accepted"
  end

end