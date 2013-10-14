require 'spec_helper'

feature 'Edit project wizard step with valid session data' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

    background do
      login_as user, scope: :user
      valid_page_one_session_data = {
        "terms"=>"1",
        "name"=>"my activity",
        "description"=>"a test activity",
        "activity_type_label"=>"Event",
        "activity_type_label_other"=>"",
        "organisation_natures"=>["http://data.digitalsocial.eu/def/concept/activity-role/sole-funder", ""]
      }
      
      page.set_rack_session(:project_page_one_data => valid_page_one_session_data.to_json)
      visit organisations_build_edit_project_path
    end

    scenario 'Filling in edit project step successfully' do
      select 'January 2013', from: 'Activity start date'
      select 'Ongoing', from: 'Activity end date'
      check 'Open Networks'
      fill_in 'Areas of Society Impacted', with: 'work and employment'
      fill_in 'Technology Method', with: 'Open Data'
      fill_in 'Social Impact', with: 'This is a social impact'

      click_button 'Next step'

      page.current_path.should include("organisations/build/invite_organisations")
    end

    scenario 'Filling in edit project step unsuccessfully (with no details)' do
      click_button 'Next step'

      # redirects back
      page.current_path.should include("organisations/build/update_project")
    end

    scenario 'Clicking a tag should fill in the appropriate field', js: true do
      page.save_screenshot '/tmp/bar.png', full: true
      click_link 'work and employment'

      find_field('project_areas_of_society_list', visible: false).value.should include('work and employment')
    end
end

feature 'Edit project wizard step with invalid session data' do
  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  scenario 'with no login session' do
    visit organisations_build_edit_project_path
    page.current_path.should include("users/sign_in")
  end

  scenario 'with a login but no partial project stored in session' do
    # this should never happen in real life.
    login_as user, scope: :user
    
    visit organisations_build_edit_project_path
    page.current_path.should include("organisations/build/new_project")
  end
end

