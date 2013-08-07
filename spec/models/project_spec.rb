require 'spec_helper'

describe Project do
  
  let(:project) { FactoryGirl.build(:project) }

  it "must have a valid factory" do
    project.should be_valid
  end

  describe "create_time_interval!" do

    it "must create an associated time interval" do
      project.create_time_interval!

      project.duration_resource.should be_persisted
      project.duration_resource.start_date.should == project.start_date
      project.duration_resource.end_date.should == project.end_date
    end

  end

  describe "add_creator_membership!" do

    it "must create the project membership" do
      organisation = FactoryGirl.create(:organisation)

      project.save
      project.add_creator_membership!(organisation)

      project_membership = ProjectMembership.first
      project_membership.project_resource.should == project
      project_membership.organisation_resource.should == organisation
    end

  end

end
