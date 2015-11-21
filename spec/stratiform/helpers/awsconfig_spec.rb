require 'spec_helper'

def mock_aws_config
  real_cfg = '~/.aws/config'
  mock_cfg = File.expand_path('../test_files/aws_config', __FILE__)
  allow(File).to receive(:expand_path).with(real_cfg).and_return(mock_cfg)
end
