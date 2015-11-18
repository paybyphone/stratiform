require 'aws-sdk'
require 'stratiform/errors'

module Stratiform
  module Helpers
    # AWS client helpers (ie: STS, S3, CloudFormation)
    module Aws
      # AWS::STS::Client helper - gets STS client to assume roles
      def sts_client(region)
        creds = Aws::SharedCredentials.new.credentials
        creds = Aws::InstanceProfileCredentials.new.credentials if creds.nil?
        if creds.nil?
          fail(
            Stratiform::Errors::NoCredentialsFoundError,
            'No shared or instance credentials found'
          )
        end
        Aws::STS::Client.new(region: region, credentials: creds).credentials
      end

      # AWS::CloudFormation::Client helper - gets CloudFormation client object
      def cloudformation_client(region, credentials)
        Aws::CloudFormation::Client.new(
          region: region, credentials: credentials
        )
      end
    end
  end
end
