require 'spec_helper'

feature 'New project' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit new_project_path
  end

  scenario 'Filling in new project step successfully' do
    check 'project_terms'
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    choose 'Research Project'
    check 'Sole funder'
    check 'Delivery Lead'
    select 'January 2011', from: 'Activity start date'
    select 'Ongoing', from: 'Activity end date'
    uncheck 'Open Networks'
    check 'Open Hardware'
    fill_in 'Areas of Society Impacted', with: 'Finance'
    fill_in 'Technology Method', with: 'Peer Support'
    fill_in 'Social Impact', with: 'This is a social impact'

    click_button 'Create'

    page.current_path.should match(/projects\/(.+)\/invite/)
  end

  scenario 'Filling in new project step unsuccessfully' do
    click_button 'Create'

    page.current_path.should_not match(/projects\/(.+)\/invite/)
  end

  scenario 'Show other field if other radio button selected', js: true do
    first('.project_activity_type_label_other').should_not be_present
    choose 'Other'
    first('.project_activity_type_label_other').should be_present
  end

  scenario 'Suggest to join an existing project', js: true do
    FactoryGirl.create(:project, name: 'A brilliant project')

    fill_in 'Name', with: 'brill'

    page.should have_content 'A brilliant project'
    page.should have_link 'Request to join'
  end

  scenario 'Fill in with specifying other field', js: true do
    check 'project_terms'
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    check 'Sole funder'
    check 'Delivery Lead'

    choose 'Other'
    fill_in 'project_activity_type_label_other', with: 'Something else'

    fill_in 'project_areas_of_society_list', with: 'Finance', visible: false
    check 'Open Hardware'
    fill_in 'project_technology_method_list', with: 'big data', visible: false
    fill_in 'Social Impact', with: 'Lorem ipsum'

    click_button 'Create'

    page.current_path.should match(/projects\/(.+)\/invite/)
  end

  scenario 'Activity type radio buttons should be validated' do
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    check 'Sole funder'
    check 'Delivery Lead'

    click_button 'Create'

    page.current_path.should_not match(/projects\/(.+)\/invite/)
    page.should have_css('.error')
  end

  scenario 'Nature checkboxes should be validated' do
    fill_in 'Name', with: 'A great project'
    fill_in 'Description', with: 'Lorem ispum'
    choose 'Research Project'

    click_button 'Create'

    page.current_path.should_not match(/projects\/(.+)\/invite/)
    page.should have_css('.project_organisation_natures .error')
  end

end
