require 'spec_helper'
require 'stratiform/stack'

describe Stratiform::Stack do
  stack = Stratiform::Stack.new('stratiform-test-stack')
  stack.targets(['stratiform-test-target'])

  it 'has the correct stack name' do
    expect(stack.name).to eq('stratiform-test-stack')
  end
  it 'will deploy to the given targets' do
    expect(stack.targets).to match_array(['stratiform-test-target'])
  end

  describe '#validate_template' do
    it 'validates the template' do
      add_stack_mocks(stack)
      target = mock_target
      resp = stack.validate_template(target)
      expect(resp.description).to eq('Description')
    end
  end

  describe '#create_stack' do
    it 'creates the stack' do
      add_stack_mocks(stack)
      target = mock_target
      stack_id = stack.create_stack(target)
      expect(stack_id).to eq('StackId')
    end
  end
end
