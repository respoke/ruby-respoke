require 'test_helper'

describe 'Brokered authentication' do
  subject { client }

  describe 'when using App-Secret' do
    let :client do
      Respoke::Client.new(app_secret: TestConfig.app_secret)
    end

    it 'requests token ID' do
      response = nil

      VCR.use_cassette 'session_token_id_request' do
        response = subject.request_session_token_id(
          appId: TestConfig.app_id,
          endpointId: 'foo-bar',
          roleId: TestConfig.role_id,
          ttl: 60
        )
      end

      assert response.tokenId?
    end

    describe 'and already given a session token ID' do
      let :token_id do
        token_id = ''

        VCR.use_cassette 'session_token_id_request' do
          token_id = subject.request_session_token_id(
            appId: TestConfig.app_id,
            endpointId: 'foo-bar',
            roleId: TestConfig.role_id,
            ttl: 60 # this is short since it's only needed in the test
          ).tokenId
        end

        token_id
      end

      it 'requests App-Token using session token ID' do
        response = nil

        VCR.use_cassette 'session_token_request' do
          response = subject.request_session_token(
            appId: TestConfig.app_id,
            tokenId: token_id,
          )
        end

        assert response.token?
      end
    end

    it 'requests an App-Token in one step' do
      token = ''

      VCR.use_cassette 'app_token_request' do
        token = subject.app_token(
          appId: TestConfig.app_id,
          endpointId: 'foo-bar',
          roleId: TestConfig.role_id,
          ttl: 60
        )
      end

      assert_instance_of String, token
      refute_equal '', token
    end

    describe 'when App-Token has already been set' do
      before do
        VCR.use_cassette 'app_token_request' do
          @expected_app_token = subject.app_token(
            appId: TestConfig.app_id,
            endpointId: 'foo-bar',
            roleId: TestConfig.role_id,
            ttl: 60
          )
        end
      end

      it 'returns that token' do
        assert_equal @expected_app_token, subject.app_token
      end
    end
  end
end
