require 'spec_helper'

feature 'New user wizard step' do

  before do
    visit organisations_build_new_user_path
  end

  scenario 'Filling in new user step successfully' do
    fill_in 'user_first_name', with: 'John'
    fill_in 'user_email', with: 'john@example.com'
    fill_in 'user_password', with: 'password123'
    click_button 'Next step'

    page.current_url.should include("organisations/build/new_organisation")
  end

  scenario 'Filling in new user step with existing email' do
    FactoryGirl.create(:user, email: 'john@example.com')

    fill_in 'user_first_name', with: 'John'
    fill_in 'user_email', with: 'john@example.com'
    fill_in 'user_password', with: 'password123'
    click_button 'Next step'

    page.current_url.should_not include("organisations/build/new_organisation")
  end

  scenario 'Filling in new user step with no password' do
    fill_in 'user_first_name', with: 'John'
    fill_in 'user_email', with: 'john@example.com'
    click_button 'Next step'

    page.current_url.should_not include("organisations/build/new_organisation")
  end

end