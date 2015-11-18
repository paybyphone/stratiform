require 'spec_helper'
require 'stratiform/target'

ROLE_ARN = 'arn:aws:iam::123456789012:role/stratiform-admin'

describe Stratiform::Target do
  target = Stratiform::Target.new('stratiform-test-target')
  target.role_arn(ROLE_ARN)
  target.region('us-east-1')

  it 'has the correct target name' do
    expect(target.name).to eq('stratiform-test-target')
  end
  it 'has the correct role ARN' do
    expect(target.role_arn).to eq(ROLE_ARN)
  end
  it 'has the correct region' do
    expect(target.region).to eq('us-east-1')
  end

  describe '#target_credentials' do
    it 'returns an access key ID for the target' do
      creds = get_mocked_creds(target)
      expect(creds.access_key_id).to eq('accessKeyIdType')
    end
    it 'returns a secret access key for the target' do
      creds = get_mocked_creds(target)
      expect(creds.secret_access_key).to eq('accessKeySecretType')
    end
    it 'returns a session token for the target' do
      creds = get_mocked_creds(target)
      expect(creds.session_token).to eq('tokenType')
    end
  end
end
