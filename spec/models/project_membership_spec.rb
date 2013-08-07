require 'spec_helper'

describe ProjectMembership do
  
  let(:project_membership) { FactoryGirl.build(:project_membership) }

  it "must have a valid factory" do
    project_membership.should be_valid
  end

end
