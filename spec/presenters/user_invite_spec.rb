require 'spec_helper'

describe UserInvitePresenter do

  let(:user_invite_presenter) { FactoryGirl.build(:user_invite_presenter) }

  it "must have a valid factory" do
    user_invite_presenter.should be_valid
  end

  it 'must not be valid if the user already belongs to the organisation' do
    user = FactoryGirl.create(:user, email: 'test@test.com')
    FactoryGirl.create(:organisation_membership, user: user, organisation_uri: user_invite_presenter.organisation.uri.to_s)
    user_invite_presenter.user_email = 'test@test.com'

    user_invite_presenter.should_not be_valid
  end

  describe '.save' do

    it 'must create a user with the correct details' do
      user_invite_presenter.save

      user_invite_presenter.user.should be_persisted
      user_invite_presenter.user.first_name.should == user_invite_presenter.user_first_name
      user_invite_presenter.user.email.should == user_invite_presenter.user_email
    end

    it 'must create an organisation membership with the correct details' do
      user_invite_presenter.save

      user_invite_presenter.organisation_membership.should be_persisted
      user_invite_presenter.organisation_membership.organisation_uri.should == user_invite_presenter.organisation.uri.to_s
      user_invite_presenter.organisation_membership.user.should == user_invite_presenter.user
      user_invite_presenter.organisation_membership.owner.should be_false
    end

    it 'should create a new user if email is new' do
      lambda { user_invite_presenter.save }.should change(User, :count).by(1)
    end

    it 'should use the existing user if email is already in use' do
      FactoryGirl.create(:user, email: 'test@test.com')
      user_invite_presenter.user_email = 'test@test.com'

      lambda { user_invite_presenter.save }.should_not change(User, :count)
    end

  end

end