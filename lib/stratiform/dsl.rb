require 'stratiform/target'
require 'stratiform/stack'

module Stratiform
  # Stratiform DSL layer - read Stratifile and perform run logic
  class DSL
    attr_reader :targets, :stacks, :run_data

    # Reads the Stratifile data in for loading. Defaults to "Stratifile"
    # in the current working directory for now.
    def self.read_stratifile
      IO.read('Stratifile')
    end

    def initialize
      @targets = {}
      @stacks = {}
    end

    # Wraps DSL for Stratiform::Target and loads in targets.
    def target(target_name, &block)
      if @targets.include?(target_name)
        fail NameError, "target with name #{target_name} already exists"
      end
      @targets[target_name] = Stratiform::Target.new(target_name, &block)
    end

    # Wraps DSL for Stratiform::Stack and loads in stacks.
    def stack(stack_name, &block)
      if @stacks.include?(stack_name)
        fail NameError, "stack with name #{stack_name} already exists"
      end
      @stacks[stack_name] = Stratiform::Stack.new(stack_name, &block)
    end

    def run_create(target_name, stack_name)
      stack = @stacks[stack_name]
      unless stack.targets.include?(target_name)
        fail(
          IndexError,
          "target #{target_name} is not a member of stack #{stack_name}"
        )
      end
      stack.create_stack
    end

    def load_stratifile
      instance_eval(self.class.read_stratifile, 'Stratifile')
    end
  end
end
