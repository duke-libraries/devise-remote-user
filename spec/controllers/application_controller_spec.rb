require 'spec_helper'

describe ApplicationController do

  controller do
    def remote_user_name=(user_name)
      request.env[DeviseRemoteUser.env_key] = user_name
    end

    def remote_user_attributes=(attrs)
      attrs.each {|k, v| request.env[k] = v }
    end
  end

  describe "remote user authentication" do
    describe "remote user exists" do
      let(:user) { FactoryGirl.create(:user) }
      after { user.delete }
      it "should login the remote user" do
        controller.remote_user_name = user.email
        get :index
        controller.user_signed_in?.should be_true
        controller.current_user.should eq(user)
      end
    end
    describe "remote user not present" do
      it "should do nothing" do
        controller.remote_user_name = nil
        get :index
        controller.user_signed_in?.should be_false
      end
    end
    describe "remote user does not exist" do
      let(:email) { "foo@bar.com" }
      describe "auto-creation enabled" do
        before { DeviseRemoteUser.auto_create = true }
        after { @user.delete }
        it "should create and sign in a new user" do
          User.find_by_email(email).should be_nil
          controller.remote_user_name = email
          get :index
          response.should be_successful
          controller.user_signed_in?.should be_true
          @user = User.find_by_email(email)
          @user.should_not be_nil
          controller.current_user.should eq(@user)
        end
      end
      describe "auto-creation disabled" do
        before { DeviseRemoteUser.auto_create = false }
        it "should not create a user for the remote user" do
          User.find_by_email(email).should be_nil
          controller.remote_user_name = email
          get :index
          response.should_not be_successful
          controller.user_signed_in?.should be_false
          User.find_by_email(email).should be_nil
        end
      end
    end
    describe "a local database user is already signed in" do
      let(:local_user) { FactoryGirl.create(:user) }
      before do
        DeviseRemoteUser.auto_create = true
        controller.remote_user_name = remote_user.email
        sign_in local_user
      end
      after { local_user.delete }
      describe "remote user exists" do
        let(:remote_user) { FactoryGirl.create(:user) }
        after { remote_user.delete }
        it "should not clobber the existing user session" do
          get :index
          controller.current_user.should eq(local_user)
          controller.current_user.should_not eq(remote_user)
        end
      end
      describe "remote user does not exist" do
        let(:remote_user) { FactoryGirl.build(:user) }
        it "should not clobber the existing user session" do
          get :index
          controller.current_user.should eq(local_user)
          controller.current_user.should_not eq(remote_user)
          User.find_by_email(remote_user.email).should be_nil
        end
      end
    end
    describe "auto-updating user attributes" do
      let(:user) { FactoryGirl.create(:user, first_name: 'Hardy', last_name: 'HarHar', nickname: "Laurel's Buddy", display_name: 'Hardy HarHar') }
      before do
        DeviseRemoteUser.attribute_map = {
          first_name: 'givenName',
          nickname: 'eduPersonNickname',
          last_name: 'sn',
          display_name: 'displayName'
          }
      end
      after { user.delete }
      describe "auto-creation disabled" do
        before { DeviseRemoteUser.auto_update = false }
        it "should not update the user attributes" do
          controller.remote_user_name = user.email
          controller.remote_user_attributes = {
            'givenName' => 'Fleece',
            'sn' => 'Vest',
            'eduPersonNickname' => 'Iconoclast',
            'displayName' => 'Fleece Vest (Iconoclast)'
          }
          get :index
          user.reload
          user.first_name.should == 'Hardy'
          user.last_name.should == 'HarHar'
          user.display_name.should == 'Hardy HarHar'
          user.nickname.should == "Laurel's Buddy"
        end
      end
      describe "auto-creation enabled" do
        before { DeviseRemoteUser.auto_update = true }
        describe "database authentication wins" do
          it "should not update the user attributes" do
            sign_in user
            controller.remote_user_attributes = {
              'givenName' => 'Fleece',
              'sn' => 'Vest',
              'eduPersonNickname' => 'Iconoclast',
              'displayName' => 'Fleece Vest (Iconoclast)'
            }
            get :index
            user.reload
            user.first_name.should == 'Hardy'
            user.last_name.should == 'HarHar'
            user.display_name.should == 'Hardy HarHar'
            user.nickname.should == "Laurel's Buddy"
          end
        end
        describe "remote user authentication wins" do
          it "should update the user attributes" do
            controller.remote_user_name = user.email
            controller.remote_user_attributes = {
              'givenName' => 'Fleece',
              'sn' => 'Vest',
              'eduPersonNickname' => 'Iconoclast',
              'displayName' => 'Fleece Vest (Iconoclast)'
            }
            get :index
            user.reload
            user.first_name.should == 'Fleece'
            user.last_name.should == 'Vest'
            user.display_name.should == 'Fleece Vest (Iconoclast)'
            user.nickname.should == 'Iconoclast'
          end
        end
      end
    end
  end

end
