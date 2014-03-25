require 'spec_helper'

feature 'Dashboard account page' do

  background do
    login_as user, scope: :user
    visit edit_user_path
  end

  context "with an organisation" do

    let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
    let(:organisation) { user.organisation_resources.first }

    scenario 'Add a new organisation link' do
      page.should have_link('Add/join another organisation', href: organisations_build_new_organisation_path)
    end

    scenario "Shows the user's organisations" do
      page.should have_content(organisation.name)
    end

  end

  context "without an organisation" do

    let(:user) { FactoryGirl.create(:user) }

    scenario 'Add a new organisation link' do
      page.should have_link('Add/join an organisation', href: organisations_build_new_organisation_path)
    end

  end
  
end