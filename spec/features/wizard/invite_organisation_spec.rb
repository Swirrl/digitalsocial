require 'spec_helper'

feature 'Invite organisation wizard step' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    project = FactoryGirl.create(:project, scoped_organisation: organisation)

    visit organisations_build_invite_organisations_path(id: project.guid)
  end

  scenario 'Suggest an organisation to invite', js: true do
    FactoryGirl.create(:organisation, name: 'Testing123')

    fill_in 'Name', with: 'testing'

    page.should have_content 'Testing123'
    page.should have_link 'Invite'
  end

  scenario 'Invite an existing organisation successfully', js: true do
    FactoryGirl.create(:organisation, name: 'Testing123')

    fill_in 'Name', with: 'testing'
    click_link 'Invite'

    page.current_path.should == dashboard_projects_path
  end

  scenario 'Invite a new organisation successfully' do
    fill_in 'Organisation Name', with: 'New org'
    fill_in 'User first name', with: 'Bob'
    fill_in 'User email', with: 'bob@test.com'

    click_button 'Next step'

    page.current_path.should == dashboard_path
  end

  scenario 'Invite a new organisation unsuccessfully' do
    click_button 'Next step'

    page.current_path.should_not == dashboard_path
    page.should have_css('.error')
  end

  scenario 'Skipping the invite organisation step' do
    page.should have_link('Skip', href: dashboard_path)
  end

end