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
    it 'has empty rundata' do
      expect(dsl.run_data).to be_empty
    end
  end

  describe '#load_stratifile' do
    it 'loads a target of the right class' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.targets[0].class.name).to eq('Stratiform::Target')
    end

    it 'sets the name of the target' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.targets[0].name).to eq('test-target')
    end

    it 'loads a stack of the right class' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      expect(dsl.stacks[0].class.name).to eq('Stratiform::Stack')
    end
  end

  describe '#target_byname' do
    it 'loads a target by name' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      target = dsl.target_byname('test-target')
      expect(target.class.name).to eq('Stratiform::Target')
    end
  end

  describe '#stack_byname' do
    it 'loads a stack by name' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      stack = dsl.stack_byname('test-stack')
      expect(stack.class.name).to eq('Stratiform::Stack')
    end
  end

  describe '#task_rundata_initialize' do
    it 'creates null run data for a task' do
      dsl = Stratiform::DSL.new
      dsl.task_rundata_initialize('test-target', 'test-stack')
      expect(dsl.run_data['test-target']['test-stack']).to be_empty
    end
  end

  describe '#run_create' do
    it 'logs the stack ID for a run' do
      dsl = Stratiform::DSL.new
      dsl_mock_and_load(dsl)
      dsl.run_create('test-target', 'test-stack')
      stack_id = dsl.run_data['test-target']['test-stack']['stack_id']
      expect(stack_id).to eq('StackId')
    end
  end
end
