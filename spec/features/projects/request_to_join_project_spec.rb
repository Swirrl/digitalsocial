require 'spec_helper'

feature 'Request to Join Project' do

  let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
  let(:project) { user.organisation.project_resources.first }

  background do
    login_as user, scope: :user
    visit organisations_build_new_project_path
  end

  scenario 'Blah' do
    page.should have_link('Skip', href: organisations_build_new_project_path)
  end

end