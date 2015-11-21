require 'spec_helper'
require 'stratiform/main'

describe Stratiform::Main do
  before(:each) do
    mock_aws_config
    @main = Stratiform::Main.new(profile: 'test-profile')
    @main.load_dsl(path: File.expand_path(
      '../helpers/test_files/Stratifile',
      __FILE__
    ))
    @main.load_aws_config(profile: 'test-profile', mfa_code: '123456')
  end

  describe '#initialize' do
    it 'creates a fresh DSL object' do
      expect(@main.dsl.class.name).to eq('Stratiform::DSL')
    end

    it 'loads a default region' do
      expect(@main.default_region).to eq('us-west-1')
    end
  end

  describe '#load_dsl' do
    it 'loads targets via DSL' do
      expect(@main.dsl.targets.length).to be > 0
    end

    it 'loads stacks via DSL' do
      expect(@main.dsl.stacks.length).to be > 0
    end
  end

  describe '#load_aws_config' do
    it 'sets up a MFA session' do
      config = Aws.config
      expect(config[:access_key_id]).to eq('accessKeyIdType')
      expect(config[:secret_access_key]).to eq('accessKeySecretType')
      expect(config[:session_token]).to eq('tokenType')
    end

    it 'sets the region off of config profile' do
      expect(Aws.config[:region]).to eq('us-west-1')
    end
  end

  describe '#prerun_actions' do
    it 'assumes the role in the target DSL' do
      expect(Aws::AssumeRoleCredentials).to receive(:new).with(hash_including(
        role_arn: 'arn:aws:iam::123456789012:role/stratiform-admin'
      )).and_call_original
      @main.prerun_actions(target_name: 'test-target')
    end
    it 'sets the region in the target DSL' do
      @main.prerun_actions(target_name: 'test-target')
      expect(Aws.config[:region]).to eq('us-east-1')
    end
  end

  describe '#run_create' do
    it 'will attempt to create the stack' do
      expect(@main.dsl.stacks['test-stack']).to receive(:create_stack)
      @main.run_create(target_name: 'test-target', stack_name: 'test-stack')
    end
  end

  describe '#postrun_actions' do
    it 'resets the credentials' do
      expect(Stratiform::AwsConfig).to receive(:reset_credentials)
      @main.postrun_actions
    end

    it 'resets the region to the default' do
      expect(@main.default_region).to eq('us-west-1')
    end
  end
end
