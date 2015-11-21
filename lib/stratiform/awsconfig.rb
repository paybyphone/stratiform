require 'inifile'
require 'aws-sdk'
require 'securerandom'

module Stratiform
  # AWS related configuration information and authentication manager
  class AwsConfig
    attr_reader :aws_default_region, :aws_default_credentials

    # Loads the config section for a specific profile.
    def self.load_config_value(profile, key)
      profile = "profile #{profile}" unless profile == 'default'
      config_file = File.expand_path('~/.aws/config')
      aws_config = IniFile.load(config_file) if File.exist?(config_file)
      nil unless aws_config
      aws_config[profile][key]
    end

    # Checks to see if MFA is required for a specific profile.
    def self.mfa_required(profile)
      if load_config_value(profile, 'mfa_serial')
        true
      else
        false
      end
    end

    # Assume role and set credentials to that role.
    def self.assume_aws_role(role_arn)
      session_name = "#{role_arn.split('/')[-1]}_#{SecureRandom.hex(8)}"
      Aws.config.update(
        credentials: Aws::AssumeRoleCredentials.new(
          role_arn: role_arn,
          role_session_name: session_name
        ).credentials
      )
    end

    # Creates an AWS session and returns the credentails object.
    def self.create_aws_session(profile, mfa_code)
      sts = Aws::STS::Client.new
      sts.get_session_token(
        serial_number: load_config_value(profile, 'mfa_serial'),
        token_code: mfa_code
      ).credentials
    end

    # Creates the base credentials
    def self.default_credentials(profile, mfa_code)
      session = create_aws_session(profile, mfa_code)
      Aws.config.update(
        access_key_id: session.access_key_id,
        secret_access_key: session.secret_access_key,
        session_token: session.session_token
      )
      reset_credentials
    end

    # resets the default credentials in Aws.config to the default credentials.
    def self.reset_credentials
      Aws.config.delete(:credentials)
    end

    # Sets defaults from config and command-line options, and configures
    # AWS session, if MFA has been supplied.
    def initialize
      @aws_default_region = nil
      @aws_default_credentials = nil
    end

    # Sets the default region from:
    #  - Supplied region (from options)
    #  - Region located in configuration
    #
    # If region is not set here, we do not set it, and region will rely on
    # either ENV['AWS_REGION'] (SDK behaviour) or static region set in target
    # config.
    def default_region(option_region, option_profile)
      config_region = self.class.load_config_value(option_profile, 'region')
      @aws_default_region = config_region if config_region
      @aws_default_region = option_region if option_region
      reset_region
    end

    # :reek:DuplicateMethodCall
    # resets the default region in Aws.config to the default region.
    def reset_region
      if @aws_default_region
        Aws.config.update(region: @aws_default_region)
      else
        Aws.config.delete(:region)
      end
    end
  end
end
