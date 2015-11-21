require 'spec_helper'
require 'stratiform/dsl'

describe Stratiform::DSL do
  describe '#initialize' do
    dsl = Stratiform::DSL.new

    it 'has an empty target list' do
      expect(dsl.targets).to be_empty
    end
    it 'has an empty stack list' do
      expect(dsl.stacks).to be_empty
    end
  end

  describe '#load_stratifile' do
    it 'loads a target of the right class' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.targets['test-target'].class.name).to eq('Stratiform::Target')
    end

    it 'sets the name of the target' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.targets['test-target'].name).to eq('test-target')
    end

    it 'loads a stack of the right class' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.stacks['test-stack'].class.name).to eq('Stratiform::Stack')
    end

    it 'sets the name of the stack' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.stacks['test-stack'].name).to eq('test-stack')
    end
  end
end
