require 'spec_helper'

feature 'Invite organisation wizard step' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  let(:project) { FactoryGirl.create(:project, scoped_organisation: organisation) }

  background do
    login_as user, scope: :user

    visit organisations_build_invite_organisations_path(id: project.guid)
  end

  scenario 'Suggest an organisation to invite', js: true do
    FactoryGirl.create(:organisation, name: 'Testing123')

    fill_in 'Organisation Name', with: 'testing'

    page.should have_content 'Testing123'
    page.should have_link 'Invite'
  end

  scenario 'Invite an existing organisation successfully' do
    organisation = FactoryGirl.create(:organisation, name: 'Testing123')

    find('#invited-organisation-id', visible: false).set(organisation.guid)
    click_button 'Next step'
    page.current_path.should == organisations_build_finish_path
  end

  scenario 'Invite an existing organisation unsuccessfully' do
    other_organisation = FactoryGirl.create(:organisation, name: 'Testing123')

    # Perhaps the most common case where a failure might occur is if
    # the other organisation is already invited to our project.
    FactoryGirl.create(:project_membership, project: project.uri, organisation: organisation.uri)
    FactoryGirl.create(:project_membership, project: project.uri, organisation: other_organisation.uri)
    
    find('#invited-organisation-id', visible: false).set(other_organisation.guid)
    click_button 'Next step'

    page.current_path.should == create_organisation_invite_project_path(project)
  end
  
  scenario 'Invite a new organisation successfully' do
    fill_in 'Organisation Name', with: 'New org'
    fill_in 'Their Name', with: 'Bob'
    fill_in 'Their email', with: 'bob@test.com'

    click_button 'Next step'

    page.current_path.should == organisations_build_finish_path
  end

  scenario 'Invite a new organisation unsuccessfully' do
    click_button 'Next step'

    page.current_path.should_not == organisations_build_finish_path
    page.should have_css('.error')
  end

  scenario 'Skipping the invite organisation step' do
    page.should have_link('Skip', href: organisations_build_finish_path)
  end

end
