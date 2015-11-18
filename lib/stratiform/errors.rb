module Stratiform
  # Exceptions for Stratiform
  module Errors
    # Raised if credentials can't be found for a target.
    class NoCredentialsFoundError < StandardError
    end
  end
end
