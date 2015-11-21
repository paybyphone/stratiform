require 'spec_helper'
require 'stratiform/awsconfig'
require 'aws-sdk'

describe Stratiform::AwsConfig do
  describe '::load_config_value' do
    it 'loads a value from the default profile' do
      mock_aws_config
      default_region = Stratiform::AwsConfig.load_config_value(
        profile: 'default',
        key: 'region'
      )
      expect(default_region).to eq('us-east-1')
    end

    it 'loads a value from a non-default profile' do
      mock_aws_config
      mfa_serial = Stratiform::AwsConfig.load_config_value(
        profile: 'test-profile',
        key: 'mfa_serial'
      )
      expect(mfa_serial).to eq('arn:aws:iam::123456789012:mfa/test')
    end
  end

  describe '::mfa_required' do
    it 'confirms MFA is required on the test profile' do
      mock_aws_config
      mfa_required = Stratiform::AwsConfig.mfa_required(
        profile: 'test-profile'
      )
      expect(mfa_required).to be true
    end
  end

  describe '::aws_config_update' do
    it 'saves the assumed role credentials in Aws.config' do
      Stratiform::AwsConfig.assume_aws_role(
        role_arn: 'arn:aws:iam::123456789012:role/stratiform-admin'
      )
      credentials = Aws.config[:credentials]
      expect(credentials.access_key_id).to eq('accessKeyIdType')
      expect(credentials.secret_access_key).to eq('accessKeySecretType')
      expect(credentials.session_token).to eq('tokenType')
    end
  end

  describe '::create_aws_session' do
    it 'creates a session and sends back credentials' do
      credentials = Stratiform::AwsConfig.create_aws_session(
        profile: 'test-profile',
        mfa_code: '123456'
      )
      expect(credentials.access_key_id).to eq('accessKeyIdType')
      expect(credentials.secret_access_key).to eq('accessKeySecretType')
      expect(credentials.session_token).to eq('tokenType')
    end
  end

  describe '::default_credentials' do
    it 'configures the default credentials' do
      mock_aws_config
      Stratiform::AwsConfig.default_credentials(
        profile: 'test-profile',
        mfa_code: '123456'
      )
      config = Aws.config
      expect(config[:access_key_id]).to eq('accessKeyIdType')
      expect(config[:secret_access_key]).to eq('accessKeySecretType')
      expect(config[:session_token]).to eq('tokenType')
    end
  end

  describe '::reset_credentials' do
    it 'clears the credentials attribute' do
      Aws.config.update(credentials: Aws::SharedCredentials.new.credentials)
      Stratiform::AwsConfig.reset_credentials
      expect(Aws.config.include?(:credentials)).to be false
    end
  end

  describe '::default_region' do
    it 'loads a region from default profile' do
      mock_aws_config
      region = Stratiform::AwsConfig.default_region
      expect(region).to eq('us-east-1')
    end

    it 'loads a region from another profile' do
      mock_aws_config
      region = Stratiform::AwsConfig.default_region(profile: 'test-profile')
      expect(region).to eq('us-west-1')
    end

    it 'loads a region from environment' do
      mock_aws_config
      ENV['AWS_REGION'] = 'eu-west-1'
      region = Stratiform::AwsConfig.default_region
      expect(region).to eq('eu-west-1')
      ENV.delete('AWS_REGION')
    end

    it 'loads a region from supplied parameter' do
      mock_aws_config
      region = Stratiform::AwsConfig.default_region(
        option_region: 'us-west-2'
      )
      expect(region).to eq('us-west-2')
    end
  end
end
