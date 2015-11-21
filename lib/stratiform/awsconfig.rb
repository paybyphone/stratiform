require 'inifile'
require 'aws-sdk'
require 'securerandom'

module Stratiform
  # AWS related configuration information and authentication manager
  module AwsConfig
    module_function

    # Loads the config section for a specific profile.
    def load_config_value(profile:, key:)
      profile = "profile #{profile}" unless profile == 'default'
      config_file = File.expand_path('~/.aws/config')
      aws_config = IniFile.load(config_file) if File.exist?(config_file)
      nil unless aws_config
      aws_config[profile][key]
    end

    # Checks to see if MFA is required for a specific profile.
    def mfa_required(profile:)
      if load_config_value(profile: profile, key: 'mfa_serial')
        true
      else
        false
      end
    end

    # Assume role and set credentials to that role.
    def assume_aws_role(role_arn:)
      session_name = "#{role_arn.split('/')[-1]}_#{SecureRandom.hex(8)}"
      Aws.config.update(
        credentials: Aws::AssumeRoleCredentials.new(
          role_arn: role_arn,
          role_session_name: session_name
        ).credentials
      )
    end

    # Creates an AWS session and returns the credentails object.
    def create_aws_session(profile:, mfa_code:)
      sts = Aws::STS::Client.new
      sts.get_session_token(
        serial_number: load_config_value(profile: profile, key: 'mfa_serial'),
        token_code: mfa_code
      ).credentials
    end

    # :reek:FeatureEnvy
    # Creates the base credentials
    def default_credentials(profile:, mfa_code:)
      session = create_aws_session(profile: profile, mfa_code: mfa_code)
      Aws.config.update(
        access_key_id: session.access_key_id,
        secret_access_key: session.secret_access_key,
        session_token: session.session_token
      )
      reset_credentials
    end

    # resets the default credentials in Aws.config to the default credentials.
    def reset_credentials
      Aws.config.delete(:credentials)
    end

    # Sets the region.
    def update_region(region:)
      Aws.config.update(region: region)
    end

    # Deletes the region.
    def delete_region
      Aws.config.delete(:region)
    end

    # Sets the default region from:
    #  - Supplied region (from options)
    #  - ENV['AWS_REGION'] if set
    #  - Region located in configuration
    #
    # If region is not set here, we do not set it, and region will rely on
    # either ENV['AWS_REGION'] (SDK behaviour) or static region set in target
    # config.
    def default_region(option_region: nil, profile: 'default')
      config_region = load_config_value(profile: profile, key: 'region')
      env_region = ENV['AWS_REGION']
      return option_region if option_region
      return env_region if env_region
      return config_region if config_region
    end
  end
end
