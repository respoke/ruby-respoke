require 'hashie'

module Respoke
  module Response
    # A response object for session token requests.
    #
    # @attr token [String] The token for use as an App-Token.
    # @attr message [String] Token request status information.
    class SessionToken < Hashie::Mash
    end
  end
end
