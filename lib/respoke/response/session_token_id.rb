require 'hashie'

module Respoke
  module Response
    # A response object for token requests.
    #
    # @attr tokenId [String] Token ID used to request an App-Token.
    # @attr appId [String] App ID App-Token is associated with.
    # @attr roleId [String] Role ID App-Token is assigned.
    # @attr endpointId [String] Endpoint ID App-Token is for.
    # @attr ttl [Number] Number of seconds App-Token is valid for.
    # @attr createdAt [DateTime] When the token request was made.
    # @attr expiryTime [DateTime] When the token expires.
    # @attr createTime [DateTime] When the token was created.
    class SessionTokenId < Hashie::Mash
      include Hashie::Extensions::Coercion

      coerce_key :createdAt, ->(time) do
        Time.parse(time).getutc
      end

      coerce_key :expiryTime, :createTime, ->(timestamp) do
        Time.at(timestamp).getutc
      end
    end
  end
end
