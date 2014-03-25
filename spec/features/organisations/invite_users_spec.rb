require 'spec_helper'

feature 'Invite users wizard step' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:organisation) { user.organisation_resources.first }

  background do
    login_as user, scope: :user
    visit invite_users_organisation_path(organisation)
  end

  scenario 'Fill in team member details successfully' do
    fill_in 'invited_users_0_first_name', with: 'Bob'
    fill_in 'invited_users_0_email', with: 'bob@test.com'

    fill_in 'invited_users_1_first_name', with: 'Jane'
    fill_in 'invited_users_1_email', with: 'jane@test.com'

    click_button 'Send'

    page.current_path.should == dashboard_users_path
  end

  scenario 'Fill in team member details without first name' do
    fill_in 'invited_users_0_first_name', with: ''
    fill_in 'invited_users_0_email', with: 'jane@test.com'

    click_button 'Send'

    page.current_path.should_not == dashboard_users_path
    page.should have_css('.error')
  end

  scenario 'Fill in team member details without email' do
    fill_in 'invited_users_0_first_name', with: 'Bob'
    fill_in 'invited_users_0_email', with: ''

    click_button 'Send'

    page.current_path.should_not == dashboard_users_path
    page.should have_css('.error')
  end

  scenario 'Fill in team member details without valid email' do
    fill_in 'invited_users_0_first_name', with: 'Bob'
    fill_in 'invited_users_0_email', with: 'bob@test'

    click_button 'Send'

    page.current_path.should_not == dashboard_users_path
    page.should have_css('.error')
  end

  scenario 'Fill in team member details with email of user already existing' do
    user = FactoryGirl.create(:user, email: "existing@test.com")

    fill_in 'invited_users_0_first_name', with: 'Bob'
    fill_in 'invited_users_0_email', with: 'existing@test.com'

    click_button 'Send'

    page.current_path.should == dashboard_users_path
  end

  scenario 'Fill in team member details with email of user already existing but already belonging to organisation' do
    user = FactoryGirl.create(:user, email: "existing@test.com")
    FactoryGirl.create(:organisation_membership, user: user, organisation_uri: organisation.uri.to_s)

    fill_in 'invited_users_0_first_name', with: 'Bob'
    fill_in 'invited_users_0_email', with: 'existing@test.com'

    click_button 'Send'

    page.current_path.should_not == dashboard_users_path
    page.should have_css('.error')
  end
  
end