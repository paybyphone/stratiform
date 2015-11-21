require 'spec_helper'

def mock_aws_config
  Aws.config = { stub_responses: true }
  real_cfg = '~/.aws/config'
  mock_cfg = File.expand_path('../test_files/aws_config', __FILE__)
  allow(File).to receive(:expand_path).and_call_original
  allow(File).to receive(:expand_path).with(real_cfg).and_return(mock_cfg)
end
