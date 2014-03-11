require 'spec_helper'

describe Devise::SessionsController do
  before { @request.env["devise.mapping"] = Devise.mappings[:user] }
  describe "logout" do
    let(:user) { FactoryGirl.create(:user) }
    describe "when user is remotely authenticated" do
      before { @request.env[DeviseRemoteUser.env_key] = user.email }
      it "should redirect to DeviseRemoteUser.logout_url" do
        expect(get :destroy).to redirect_to(DeviseRemoteUser.logout_url)
      end
    end
    describe "when user is not remotely authenticated" do
      it "should redirect to the root path (Devise default)" do
        expect(get :destroy).to redirect_to(root_path)
      end
    end
  end

end
