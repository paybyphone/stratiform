require 'simplecov'
SimpleCov.start

require 'stratiform'
require 'aws-sdk'

RSpec.configure do |config|
  config.color = true

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
end

MOCK_TEMPALTE = <<-EOH.gsub(/^ {2}/, '')
  {
    "AWSTemplateFormatVersion": "2010-09-09",
    "Description": "stratiform-test",
    "Resources": {
      "DummyResource": {
         "Type" : "AWS::CloudFormation::WaitConditionHandle",
         "Properties" : {
         }
      }
    }
  }
EOH

# Create mocks for Stratiform::Stack
def add_stack_mocks(obj)
  allow(obj).to receive(:read_template).and_return(MOCK_TEMPALTE)
  allow(obj).to receive(:cloudformation_client).and_return(
    Aws::CloudFormation::Client.new(stub_responses: true)
  )
end

# Credentials mock for Stratiform::Target
def get_mocked_creds(obj)
  allow(obj).to receive(:sts_client).and_return(
    Aws::STS::Client.new(stub_responses: true)
  )
  obj.target_credentials
end

def mock_target
  double('Stratiform::Target', region: 'us-east-1', target_credentials: nil)
end

# Create mocks for Startiform::DSL
MOCK_STRATIFILE = <<-EOH.gsub(/^ {2}/, '')
  target 'test-target' do
    role_arn 'arn:aws:iam::123456789012:role/stratiform-admin'
    region 'us-east-1'
  end

  stack 'test-stack' do
    targets ['test-target']
  end
EOH

def dsl_mock_and_load(dsl)
  allow(dsl).to receive(:read_stratifile).and_return(MOCK_STRATIFILE)
  dsl.load_stratifile
  dsl.targets.each do |target|
    allow(target).to receive(:sts_client).and_return(
      Aws::STS::Client.new(stub_responses: true)
    )
  end
  dsl.stacks.each do |stack|
    add_stack_mocks(stack)
  end
end
