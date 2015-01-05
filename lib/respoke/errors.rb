
module Respoke
  # Contains custom error classes for better raises and error logging.
  module Errors
      # A catch all error for unspecified server errors.
    class UnexpectedServerError < StandardError
    end
  end
end
