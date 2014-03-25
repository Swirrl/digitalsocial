require 'spec_helper'

describe Organisation do

  describe "validations" do
    let(:organisation) { FactoryGirl.build(:organisation) }

    it "must have a valid factory" do
      organisation.should be_valid
    end

  end

  describe '.destroy' do

    context 'with no associated projects' do
      let(:organisation) { FactoryGirl.create(:organisation) }

      it 'should remove the organisation' do
        organisation.save
        lambda { organisation.destroy }.should change(Organisation, :count).by(-1)
      end

    end

    context 'with solely associated projects' do
      let(:organisation) { FactoryGirl.create(:organisation_with_projects, projects_count: 3) }

      it 'should remove the organisation' do
        organisation.save
        lambda { organisation.destroy }.should change(Organisation, :count).by(-1)
      end

      it 'should remove the projects' do
        organisation.save
        lambda { organisation.destroy }.should change(Project, :count).by(-3)
      end

      it 'should remove the project memberships' do
        organisation.save
        lambda { organisation.destroy }.should change(ProjectMembership, :count).by(-3)
      end

    end 

    context 'with shared associated projects' do
      let(:organisation) { FactoryGirl.create(:organisation_with_projects, projects_count: 3) }

      before(:each) do
        shared_project = organisation.projects.first
        other_organisation = FactoryGirl.create(:organisation)
        FactoryGirl.create(:project_membership, project: shared_project.uri.to_s, organisation: other_organisation.uri.to_s)
      end

      it 'should remove the organisation' do
        lambda { organisation.destroy }.should change(Organisation, :count).by(-1)
      end

      it 'should not remove the shared associated projects' do
        organisation.save
        lambda { organisation.destroy }.should change(Project, :count).by(-2)
      end

      it 'should remove the project memberships' do
        organisation.save
        lambda { organisation.destroy }.should change(ProjectMembership, :count).by(-3)
      end
    end

    context 'with users' do
      let(:organisation) { FactoryGirl.create(:organisation_with_users, users_count: 3) }

      it 'should not remove the users' do
        organisation.save
        lambda { organisation.destroy }.should_not change(User, :count)
      end

      it 'should remove the organisation memberships' do
        organisation.save
        lambda { organisation.destroy }.should change(OrganisationMembership, :count).by(-3)
      end
    end

  end

end