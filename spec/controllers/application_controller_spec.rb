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

  after { User.destroy_all }

  describe "remote user authentication" do

    describe "when remote user exists" do
      let(:user) { FactoryGirl.create(:user) }
      before { controller.remote_user_name = user.email }
      it "should login the remote user" do
        get :index
        expect(controller.user_signed_in?).to be_true
        expect(controller.current_user).to eq(user)
      end
    end

    describe "when remote user is not present" do
      before { controller.remote_user_name = nil }
      it "should do nothing" do
        get :index
        expect(controller.user_signed_in?).to be_false
      end
    end

    describe "when remote user does not exist" do
      let(:email) { "foo@bar.com" }
      before { controller.remote_user_name = email }

      describe "and auto-creation is enabled" do
        before { allow(DeviseRemoteUser).to receive(:auto_create) { true } }
        it "should create and sign in a new user" do
          get :index
          expect(response).to be_successful
          expect(controller.user_signed_in?).to be_true
          expect(User.find_by_email(email)).to eq(controller.current_user)
        end
      end

      describe "and auto-creation is disabled" do
        before { allow(DeviseRemoteUser).to receive(:auto_create) { false } }
        it "should not create a user for the remote user" do
          get :index
          response.should_not be_successful
          controller.user_signed_in?.should be_false
          User.find_by_email(email).should be_nil
        end
      end
    end

    describe "when a local database user is already signed in" do
      let(:local_user) { FactoryGirl.create(:user) }
      before do
        allow(DeviseRemoteUser).to receive(:auto_create) { true }
        controller.remote_user_name = remote_user.email
        sign_in local_user
      end

      describe "and remote user exists" do
        let(:remote_user) { FactoryGirl.create(:user) }
        it "should not clobber the existing user session" do
          get :index
          expect(controller.current_user).to eq(local_user)
          expect(controller.current_user).not_to eq(remote_user)
        end
      end

      describe "and remote user does not exist" do
        let(:remote_user) { FactoryGirl.build(:user) }
        it "should not clobber the existing user session" do
          get :index
          expect(controller.current_user).to eq(local_user)
          expect(controller.current_user).not_to eq(remote_user)
          expect(User.find_by_email(remote_user.email)).to be_nil
        end
      end
    end

    describe "auto-updating user attributes" do
      let(:user) { FactoryGirl.create(:user, first_name: 'Hardy', last_name: 'HarHar', nickname: "Laurel's Buddy", display_name: 'Hardy HarHar') }
      before do
        allow(DeviseRemoteUser).to receive(:attribute_map) do
          { first_name: 'givenName', 
            nickname: 'eduPersonNickname', 
            last_name: 'sn', 
            display_name: 'displayName' } 
        end
      end

      describe "when auto-creation is disabled" do
        before do
          allow(DeviseRemoteUser).to receive(:auto_update) { false } 
          controller.remote_user_name = user.email
          controller.remote_user_attributes = {
            'givenName' => 'Fleece',
            'sn' => 'Vest',
            'eduPersonNickname' => 'Iconoclast',
            'displayName' => 'Fleece Vest (Iconoclast)'
          }
        end
        it "should not update the user attributes" do
          get :index
          user.reload
          expect(user.first_name).to eq('Hardy')
          expect(user.last_name).to eq('HarHar')
          expect(user.display_name).to eq('Hardy HarHar')
          expect(user.nickname).to eq("Laurel's Buddy")
        end
      end

      describe "when auto-creation is enabled" do
        before do
          allow(DeviseRemoteUser).to receive(:auto_update) { true }
          controller.remote_user_attributes = {
            'givenName' => 'Fleece',
            'sn' => 'Vest',
            'eduPersonNickname' => 'Iconoclast',
            'displayName' => 'Fleece Vest (Iconoclast)'
          }
        end

        describe "and database authentication wins" do
          before { sign_in user }
          it "should not update the user attributes" do
            get :index
            user.reload
            expect(user.first_name).to eq('Hardy')
            expect(user.last_name).to eq('HarHar')
            expect(user.display_name).to eq('Hardy HarHar')
            expect(user.nickname).to eq("Laurel's Buddy")
          end
        end

        describe "and remote user authentication wins" do
          before do
            controller.remote_user_name = user.email
            controller.remote_user_attributes = {
              'givenName' => 'Fleece',
              'sn' => 'Vest',
              'eduPersonNickname' => 'Iconoclast',
              'displayName' => 'Fleece Vest (Iconoclast)'
            }
          end
          it "should update the user attributes" do
            get :index
            user.reload
            expect(user.first_name).to eq('Fleece')
            expect(user.last_name).to eq('Vest')
            expect(user.display_name).to eq('Fleece Vest (Iconoclast)')
            expect(user.nickname).to eq('Iconoclast')
          end
        end
      end
    end

  end

end
