require 'faraday'
require 'faraday_middleware'

require 'respoke/errors'
require 'respoke/response'

# Contains methods to make API calls.
#
# @example One-step endpoint authentication
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
#
#     session_id_response = client.request_session_token_id(
#       appId: '0cdf7bc1-45d1-420a-963e-c797a6f7ba61',
#       roleId: '47ea573f-5a78-42f4-927c-fe658bc00f91',
#       endpointId: 'foo-bar-user'
#     )
#     session = client.request_session_token(
#       appId: session_id_response.appId,
#       tokenId: session_id_response.tokenId
#     )
#
#     session.token #=> '3c022dbd-0a82-4382-bd0d-5af6e11b8d67'
#
#     # OR you can just use Client#app_token since Client#request_session_token
#     # sets `@app_token`.
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

  # Get the roles
  #
  # @return [Array<Respoke::Role>]  An array of role objects
  # @raise [Respoke::Errors::UnexpectedServerError] if errors occur
  def roles()
    response = connection.get 'roles'

    if response.status != 200
      raise Respoke::Errors::UnexpectedServerError, <<-ERR
        request failed with status #{response.status}:
        #{response.body}
      ERR
    else
      response.body.map { |r| Respoke::Role.new(self, r.each_with_object({}) { |(k,v), h| h[k.to_sym] = v} ) }
    end
  end

  # Create a role
  #
  # @param name [String]  The name of the role
  # @param rules [Hash]  The permissions for the role
  #
  # @return [Respoke::Role]  The role that was created
  # @raise [Respoke::Errors::UnexpectedServerError] if errors occur
  def create_role(name:, rules: {})
    response = connection.post 'roles' do |request|
      request.body = rules.merge( name: name )
    end

    if response.status != 200
      raise Respoke::Errors::UnexpectedServerError, <<-ERR
        request failed with status #{response.status}:
        #{response.body}
      ERR
    else
      Respoke::Role.new(self, response.body.each_with_object({}) { |(k,v), h| h[k.to_sym] = v} )
    end
  end


  # Find a role
  #
  # @param id [String]  The id of the role to retrieve
  #
  # @return [Respoke::Role]  The role that was retrieved, nil if none found
  # @raise [Respoke::Errors::UnexpectedServerError] if errors occur
  def find_role(id:)
    response = connection.get "roles/#{id}"

    if response.status == 404
      nil
    elsif !response.success?
      raise Respoke::Errors::UnexpectedServerError, <<-ERR
        request failed with status #{response.status}:
        #{response.body}
      ERR
    else
      Respoke::Role.new(self, response.body.each_with_object({}) { |(k,v), h| h[k.to_sym] = v} )
    end
  end

  # Update a role
  #
  # @param id [String]    The id of the role to update
  # @param rules [Hash]   The new permissions for the role
  #
  # @return [Boolean]     true if successfully updated
  # @raise [Respoke::Errors::UnexpectedServerError] if errors occur
  def update_role(id:, rules:)
    response = connection.put "roles/#{id}" do |request|
      request.body = rules
    end

    if !response.success?
      raise Respoke::Errors::UnexpectedServerError, <<-ERR
        request failed with status #{response.status}:
        #{response.body}
      ERR
    else
      true
    end
  end

  # Delete a role
  #
  # @param id [String]  The id of the role to retrieve
  #
  # @return [Boolean]  true if the role was deleted, false otherwise
  def delete_role(id:)
    response = connection.delete "roles/#{id}"
    response.success?
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
