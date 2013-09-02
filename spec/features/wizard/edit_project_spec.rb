require 'spec_helper'

feature 'Edit project wizard step' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }
  #let(:project) { FactoryGirl.create(:project, scoped_organisation: organisation) }

  background do
    login_as user, scope: :user
    FactoryGirl.create(:project, scoped_organisation: organisation)

    visit organisations_build_edit_project_path
  end

  scenario 'Filling in edit project step successfully' do
    select 'January 2013', from: 'Activity start date'
    select 'Ongoing', from: 'Activity end date'
    check 'Open Networks'
    fill_in 'Areas of Society Impacted', with: 'Work And Employment'
    fill_in 'Technology Method', with: 'Open Data'

    click_button 'Next step'

    page.current_path.should include("organisations/build/invite_organisations")
  end

  scenario 'Filling in edit project step successfully with no details' do
    click_button 'Next step'

    page.current_path.should include("organisations/build/invite_organisations")
  end

  scenario 'Skipping the edit project step' do
    project = organisation.project_resources.first
    page.should have_link('Skip', href: organisations_build_invite_organisations_path(id: project.guid))
  end

  scenario 'Clicking a tag should fill in the appropriate field', js: true do
    click_link 'Work And Employment'

    find_field('project_areas_of_society_list', visible: false).value.should include('Work And Employment')
  end

end