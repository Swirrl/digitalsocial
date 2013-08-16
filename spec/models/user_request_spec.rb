require 'spec_helper'

describe UserRequest do
  
  let(:user_request) { FactoryGirl.build(:user_request) }

  it "must have a valid factory" do
    user_request.should be_valid
  end

  describe 'validations' do

    it 'must validate email does not already belong to the organisation' do
      user = FactoryGirl.create(:user_with_organisations, organisations_count: 1)
      organisation = user.organisation_resources.first

      user_request.user_email     = user.email
      user_request.requestable_id = organisation.uri.to_s

      user_request.should_not be_valid
    end

    it 'must validate an unresponded duplicate request does not already exist' do
      FactoryGirl.create(:user_request, responded_to: false, requestable_id: user_request.requestable_id, user_email: user_request.user_email)

      user_request.should_not be_valid
    end

    it 'must not validate a responded duplicate request' do
      FactoryGirl.create(:user_request, responded_to: true, requestable_id: user_request.requestable_id, user_email: user_request.user_email)

      user_request.should be_valid
    end
  end

end
