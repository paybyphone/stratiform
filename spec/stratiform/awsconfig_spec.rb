require 'spec_helper'
require 'stratiform/awsconfig'
require 'aws-sdk'

module Stratiform
  describe 'Stratiform::AWSConfig' do
    describe '::load_config_value' do
      it 'loads a value from the default profile' do
        mock_aws_config
        default_region = AwsConfig.load_config_value('default', 'region')
        expect(default_region).to eq('us-east-1')
      end

      it 'loads a value from a non-default profile' do
        mock_aws_config
        mfa_serial = AwsConfig.load_config_value('test-profile', 'mfa_serial')
        expect(mfa_serial).to eq('arn:aws:iam::123456789012:mfa/test')
      end
    end

    describe '::mfa_required' do
      it 'confirms MFA is required on the test profile' do
        mock_aws_config
        expect(AwsConfig.mfa_required('test-profile')).to be true
      end
    end

    describe '::aws_config_update' do
      it 'saves the assumed role credentials in Aws.config' do
        AwsConfig.assume_aws_role('arn:aws:iam::123456789012:role/stratiform-admin')
        credentials = Aws.config[:credentials]
        expect(credentials.access_key_id).to eq('accessKeyIdType')
        expect(credentials.secret_access_key).to eq('accessKeySecretType')
        expect(credentials.session_token).to eq('tokenType')
      end
    end

    describe '::create_aws_session' do
      it 'creates a session and sends back credentials' do
        credentials = AwsConfig.create_aws_session('test-profile', '123456')
        expect(credentials.access_key_id).to eq('accessKeyIdType')
        expect(credentials.secret_access_key).to eq('accessKeySecretType')
        expect(credentials.session_token).to eq('tokenType')
      end
    end

    describe '::default_credentials' do
      it 'configures the default credentials' do
        mock_aws_config
        AwsConfig.default_credentials('test-profile', '123456')
        config = Aws.config
        expect(config[:access_key_id]).to eq('accessKeyIdType')
        expect(config[:secret_access_key]).to eq('accessKeySecretType')
        expect(config[:session_token]).to eq('tokenType')
      end
    end

    describe '::reset_credentials' do
      it 'clears the credentials attribute' do
        Aws.config.update(credentials: Aws::SharedCredentials.new.credentials)
        AwsConfig.reset_credentials
        expect(Aws.config.include?(:credentials)).to be false
      end
    end

    describe '#default_region' do
      it 'loads a region from default profile' do
        mock_aws_config
        config = AwsConfig.new
        config.default_region(nil, 'default')
        expect(config.aws_default_region).to eq('us-east-1')
      end

      it 'loads a region from another profile' do
        mock_aws_config
        config = AwsConfig.new
        config.default_region(nil, 'test-profile')
        expect(config.aws_default_region).to eq('us-west-1')
      end

      it 'loads a region from supplied parameter' do
        mock_aws_config
        config = AwsConfig.new
        config.default_region('us-west-2', 'default')
        expect(config.aws_default_region).to eq('us-west-2')
      end
    end

    describe '#reset_region' do
      it 'resets AWS region back to instance default region' do
        config = AwsConfig.new
        config.default_region('us-west-2', nil)
        Aws.config.update(region: 'us-east-1')
        config.reset_region
        expect(Aws.config[:region]).to eq('us-west-2')
      end
    end
  end
end
