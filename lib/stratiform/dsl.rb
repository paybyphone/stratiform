require 'stratiform/target'
require 'stratiform/stack'

module Stratiform
  # Stratiform DSL layer - read Stratifile and perform run logic
  class DSL
    attr_reader :targets, :stacks, :run_data

    def initialize
      @targets = []
      @stacks = []
      @run_data = {}
    end

    # Wraps DSL for Stratiform::Target and loads in targets.
    def target(name, &block)
      if @targets.index { |x| true if x.name == name }
        fail NameError, "target with name #{name} already exists"
      end
      @targets.push(Stratiform::Target.new(name, &block))
    end

    # Wraps DSL for Stratiform::Stack and loads in stacks.
    def stack(name, &block)
      if @stacks.index { |x| true if x.name == name }
        fail NameError, "stack with name #{name} already exists"
      end
      @stacks.push(Stratiform::Stack.new(name, &block))
    end

    def run_create(target_name, stack_name)
      target = target_byname(target_name)
      stack = stack_byname(stack_name)
      task_rundata_initialize(target_name, stack_name)
      unless stack.targets.include?(target_name)
        fail(
          IndexError,
          "target #{target_name} is not a member of stack #{stack_name}"
        )
      end
      task_rundata = @run_data[target_name][stack_name]
      task_rundata['stack_id'] = stack.create_stack
    end

    def load_stratifile
      instance_eval(read_stratifile, 'Stratifile')
    end

    def report_actions
    end

    # Reads the Stratifile data in for loading. Defaults to "Stratifile"
    # in the current working directory for now.
    def read_stratifile
      IO.read('Stratifile')
    end

    # initializes the run data for a task
    def task_rundata_initialize(target_name, stack_name)
      @run_data[target_name] ||= {}
      @run_data[target_name][stack_name] ||= {}
    end

    def target_byname(name)
      index = @targets.index { |x| true if x.name == name }
      @targets[index]
    end

    def stack_byname(name)
      index = @stacks.index { |x| true if x.name == name }
      @stacks[index]
    end
  end
end
