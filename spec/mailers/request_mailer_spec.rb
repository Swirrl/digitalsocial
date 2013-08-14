require "spec_helper"

describe RequestMailer do

  describe ".request_digest" do
  
    let(:user) { FactoryGirl.create(:user_with_organisations, organisations_count: 1) }
    let(:organisation) { user.organisation_resources.first }

    it 'should be set to be delivered to the email passed in' do
      RequestMailer.request_digest(user, organisation).should deliver_to(user.email)
    end

    it 'should contain the names of the projects they are invited to' do
      request = FactoryGirl.create(:project_request, requestor: organisation, is_invite: true, responded_to: false)

      RequestMailer.request_digest(user, organisation).should have_body_text(request.requestable.label)
    end

    it 'should contain the names of the organisations that made requests and the projects they want to join' do
      pm = FactoryGirl.create(:project_membership, organisation: organisation.uri.to_s)
      request = FactoryGirl.create(:project_request, is_invite: false, responded_to: false, requestable: pm.project_resource)

      RequestMailer.request_digest(user, organisation).should have_body_text(request.requestor.name)
      RequestMailer.request_digest(user, organisation).should have_body_text(request.requestable.label)
    end

    it 'should contain a link to the projects path of the organisation' do
      request = FactoryGirl.create(:project_request, requestor: organisation, is_invite: true, responded_to: false)

      RequestMailer.request_digest(user, organisation).should have_body_text("/projects?auth_token=#{user.authentication_token}&org_id=#{organisation.guid}")
    end

    it 'should contain the details of users to be added' do
      request = FactoryGirl.create(:user_request, requestable: organisation, user_first_name: 'Bob', user_email: 'bob@swirrl.com', responded_to: false)

      RequestMailer.request_digest(user, organisation).should have_body_text('Bob')
      RequestMailer.request_digest(user, organisation).should have_body_text('bob@swirrl.com')
    end

    it 'should not contain the details of users whose requests have been responded to' do
      request = FactoryGirl.create(:user_request, requestable: organisation, user_first_name: 'Fred', user_email: 'fred@swirrl.com', responded_to: true)

      RequestMailer.request_digest(user, organisation).should_not have_body_text('Fred')
      RequestMailer.request_digest(user, organisation).should_not have_body_text('fred@swirrl.com')
    end

  end

end
