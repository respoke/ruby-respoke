require 'faraday'
require 'faraday_middleware'

require 'respoke/errors'
require 'respoke/response'

# Contains methods to make API calls.
#
# @example Simple endpoint authentication
#
#   require 'respoke'
#
#   client = Respoke::Client.new(app_secret: '77269d84-d7f3-49da-8eab-bd6686160035')
#   client.app_token(
#     appId: '0cdf7bc1-45d1-420a-963e-c797a6f7ba61',
#     roleId: '47ea573f-5a78-42f4-927c-fe658bc00f91',
#     endpointId: 'foo-bar-user'
#   )
#   #=> '3c022dbd-0a82-4382-bd0d-5af6e11b8d67'
#
# @example Manual endpoint authentication
#
#     require 'respoke'
#
#     client = Respoke::Client.new(app_secret: '77269d84-d7f3-49da-8eab-bd6686160035')
#     client.app_token #=> '3c022dbd-0a82-4382-bd0d-5af6e11b8d67'
#
# @attr_reader app_token
#
class Respoke::Client

  # Default base_url
  DEFAULT_BASE_URL = 'https://api.respoke.io/v1'

  # Base URL used for API requests
  attr_reader :base_url

  # Sets the App-Secret token
  attr_reader :app_secret

  # Creates a new Client instance.
  #
  # @param app_secret [String] The application App-Secret token.
  #   (Defaults to nil)
  # @param base_url [String] Overrides the {DEFAULT_BASE_URL} constant.
  #   (Defaults to {DEFAULT_BASE_URL})
  #
  # @return [Respoke::Client]
  def initialize(app_secret: nil, base_url: DEFAULT_BASE_URL)
    @base_url = base_url
    @app_secret = app_secret
  end

  # Either returns the current `@app_token` or sets it based on the parameter
  # Hash `token_request_params`.
  #
  # @param token_request_params [Hash] parameters for
  #   {#request_session_token_id}.
  # @option token_request_params [String] appId The application ID.
  # @option token_request_params [String] roleId Role ID to use for permissions
  #   on given endpoint ID.
  # @option token_request_params [String] endpointId The endpoint ID to
  #   authenticate.
  # @option token_request_params [Number] ttl (86400) Length of time token is
  #   valid.
  #
  # @return [String] App-Token value.
  def app_token(token_request_params={})
    @app_token ||= (
      if token_request_params
        response = request_session_token_id(token_request_params)
        request_session_token(
          appId: response.appId,
          tokenId: response.tokenId
        ).token
      end
    )
  end

  # Request a token ID for use in requesting the App-Token value.
  #
  # @todo test return value
  #
  # @param appId [String] The application ID that matches the App-Secret.
  # @param roleId [String] The role ID to use for the given endpoint.
  # @param endpointId [String] The endpoint ID that is being authenticated.
  # @param ttl [Number] The amount of time in seconds the App-Token is
  #   valid. (Defaults to 86400)
  #
  # @return [Respoke::Response::SessionTokenId] The API response object.
  def request_session_token_id(appId:, roleId:, endpointId:, ttl: 86400)
    response = connection.post 'tokens' do |request|
      request.body = {
        appId: appId,
        endpointId: endpointId,
        roleId: roleId,
        ttl: 86400
      }
    end

    if response.status != 200
      raise Respoke::Errors::UnexpectedServerError, <<-ERR
        request failed with status #{response.status}:
        #{response.body}
      ERR
    else
      Respoke::Response::SessionTokenId.new(response.body)
    end
  end

  # Request the session token using the tokenId retrived with
  # {#request_session_token_id}. This method sets the `app_token` attribute.
  #
  # @todo test setting of `@app_token`.
  #
  # @param appId [String] The application ID used in the token request.
  # @param tokenId [String] The token ID requested from
  #   {#request_session_token_id}.
  #
  # @return [Respoke::Response::SessionToken] The API response object.
  def request_session_token(appId:, tokenId:)
    response = connection.post 'session-tokens' do |request|
      request.body = {
        appId: appId,
        tokenId: tokenId
      }
    end
    @app_token = response.body.fetch('token', nil)

    if response.status != 200
      raise Respoke::Errors::UnexpectedServerError, <<-ERR
        request failed with status #{response.status}:
        #{response.body}
      ERR
    else
      Respoke::Response::SessionToken.new(response.body)
    end
  end

  private

  # Creates a Faraday connection object to make requests with.
  #
  # @return [Faraday::Connection] The connection object for making API requests.
  def connection
    @connection ||= Faraday.new(
      url: @base_url,
      headers: { :'App-Secret' => @app_secret }
    ) do |faraday|
      faraday.request :json

      faraday.response :json, :content_type => 'application/json'

      faraday.adapter Faraday.default_adapter
    end
  end
end
