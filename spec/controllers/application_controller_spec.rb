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

    describe "when remote user is not present" do
      before { controller.remote_user_name = nil }
      describe "and login_url is configured" do
        before { allow(DeviseRemoteUser).to receive(:login_url) { login_url } }
        describe "with a proc" do
          let(:login_url) { Proc.new { |env| "http://example.com/login?return_to=#{env['REQUEST_URI']}" } }
          before do
            request.env["REQUEST_URI"] = "/"            
          end
          it "should redirect to the result of the proc" do
            expect(get :index).to redirect_to("http://example.com/login?return_to=/")
          end
        end
        describe "as a string" do
          let(:login_url) { "http://example.com/login" }
          it "should redirect to the login_url" do
            expect(get :index).to redirect_to(login_url)
          end
        end
      end
      describe "and login_url is not configured" do
        it "should do nothing" do
          get :index
          expect(controller.user_signed_in?).to be_false
        end
      end
    end

    describe "when remote user is present" do
      describe "and remote user exists in database" do
        let(:user) { FactoryGirl.create(:user) }
        before { controller.remote_user_name = user.email }
        it "should login the remote user" do
          get :index
          expect(controller.user_signed_in?).to be_true
          expect(controller.current_user).to eq(user)
        end
      end

      describe "and remote user does not exist in database" do
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
    end

    describe "when a local database user is already signed in" do
      let(:local_user) { FactoryGirl.create(:user) }
      before do
        allow(DeviseRemoteUser).to receive(:auto_create) { true }
        controller.remote_user_name = remote_user.email
        sign_in local_user
      end

      describe "and remote user exists in database" do
        let(:remote_user) { FactoryGirl.create(:user) }
        it "should not clobber the existing user session" do
          get :index
          expect(controller.current_user).to eq(local_user)
          expect(controller.current_user).not_to eq(remote_user)
        end
      end

      describe "and remote user does not exist in database" do
        let(:remote_user) { FactoryGirl.build(:user) }
        it "should not clobber the existing user session" do
          get :index
          expect(controller.current_user).to eq(local_user)
          expect(controller.current_user).not_to eq(remote_user)
        end
      end
    end # local database user signed in

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
