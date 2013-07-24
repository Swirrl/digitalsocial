require 'spec_helper'

feature 'Signing up' do

  scenario 'Uninvited user signs up with no details' do
    visit new_user_path
    click_button 'Submit'

    page.should have_css '#new_user .field_with_errors'
  end

  scenario 'Uninvited user signs up with valid details' do
    visit new_user_path
    fill_in 'First name', with: 'John'
    fill_in 'Email', with: 'john@example.com'
    fill_in 'Password', with: 'password123'
    click_button 'Submit'

    page.should have_content 'Successfully signed up'
  end
end