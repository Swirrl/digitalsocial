require 'spec_helper'

feature 'Project index spec' do

  background do
    FactoryGirl.create(:project, name: 'SomeGreatProject')
  end

  scenario 'Projects are listed' do
    visit projects_path
    page.should have_content 'SomeGreatProject'
  end

  scenario 'Search for an existing project' do
    visit projects_path(q: 'somegreatproject')
    page.should have_content 'SomeGreatProject'
  end

  scenario 'Search for an non existing project' do
    visit projects_path(q: 'foobar')
    page.should_not have_content 'SomeGreatProject'
  end
  
end