require 'spec_helper'

RSpec.describe DeviseRemoteUser do
  context ".remote_user_id" do
    let(:mock_env) { { 'REMOTE_USER' => 'some-id' } }
    context "with a string for the env_key" do
      before do
        allow(DeviseRemoteUser).to receive(:env_key).and_return("REMOTE_USER")
      end
      
      it "should retrieve the key from the env" do
        expect(DeviseRemoteUser.remote_user_id(mock_env)).to eq "some-id"
      end
    end
  
    context "with a proc for the env_key" do
      before do
        allow(DeviseRemoteUser).to receive(:env_key).and_return lambda { |env| "#{env['REMOTE_USER']}@example.com" }
      end
      
      it "should retrieve the key from the env" do
        expect(DeviseRemoteUser.remote_user_id(mock_env)).to eq "some-id@example.com"
      end
    end

    describe 'create_user' do
      before do
        allow(Devise.mappings[:user]).to receive(:strategies).and_return(stratagies)
      end

      let(:manager) { DeviseRemoteUser::Manager.new(User, 'REMOTE_USER' => 'some-id') }
      context 'with a user that is database authenticatable' do
        let(:stratagies) { [:database_authenticatable] }
        it 'returns a user with a paswword' do
          expect(User).to receive(:create).with(hash_including(:password))
          manager.create_user
        end
      end

      context 'with a user that is not database authenticatable' do
        let(:stratagies) { [] }

        it 'returns a user without a paswword' do
          expect(User).to receive(:create).with(hash_excluding(:password))
          manager.create_user
        end
      end
    end
  end
end
