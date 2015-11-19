require 'thor'
require 'stratiform/dsl'

module Stratiform
  # CLI class for stratiform and main entry point
  class Main < Thor
    def initialize(*args)
      super
      begin
        @dsl = Stratiform::DSL.new
        @dsl.load_stratifile
      rescue
        puts 'Error loading your Stratifile! Fix the errors and try again.'
        raise
      end
    end

    desc 'create', 'Create a stack'
    def create(target, stack)
      @dsl.run_create(target, stack)
    end
  end
end
