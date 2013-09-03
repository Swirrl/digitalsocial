require 'spec_helper'

feature 'Project index spec' do

  scenario 'Projects are listed' do
    FactoryGirl.create(:project, name: 'SomeGreatProject')
    visit projects_path

    page.should have_content 'SomeGreatProject'
  end
  
end