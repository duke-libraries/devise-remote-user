require 'spec_helper'

describe DeviseRemoteUser do
  context ".remote_user_id" do
    let(:mock_env) { { 'REMOTE_USER' => 'some-id' } }
    context "with a string for the env_key" do
      before do
        allow(DeviseRemoteUser).to receive(:env_key) { "REMOTE_USER" }
      end
      
      it "should retrieve the key from the env" do
        expect(DeviseRemoteUser.remote_user_id(mock_env)).to eq "some-id"
      end
    end
  
    context "with a proc for the env_key" do
      before do
        allow(DeviseRemoteUser).to receive(:env_key) { lambda { |env| "#{env['REMOTE_USER']}@example.com" } }
      end
      
      it "should retrieve the key from the env" do
        expect(DeviseRemoteUser.remote_user_id(mock_env)).to eq "some-id@example.com"
      end
    end
  end
end
