require 'aws-sdk'
require 'securerandom'
require 'stratiform/helpers/aws'

module Stratiform
  # Target resource - define a target AWS account for deployment
  class Target
    include Stratiform::Helpers::Aws

    def initialize(name, &block)
      @name = name
      instance_eval(&block) unless block.nil?
    end

    def name(arg = nil)
      @name = arg unless arg.nil?
      @name
    end

    def role_arn(arg = nil)
      @role_arn = arg unless arg.nil?
      @role_arn
    end

    def region(arg = nil)
      @region = arg unless arg.nil?
      @region
    end

    def target_credentials
      session_id = "#{@name}-#{SecureRandom.hex(8)}"
      Aws::AssumeRoleCredentials.new(
        client: sts_client(@region),
        role_arn: @role_arn,
        role_session_name: session_id
      ).credentials
    end
  end
end
