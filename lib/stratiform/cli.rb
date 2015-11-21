require 'stratiform/dsl'
require 'stratiform/awsconfig'
require 'thor'
require 'inifile'

module Stratiform
  # CLI class for stratiform and main entry point
  class CLI < Thor
    def initialize(*args)
      super
      begin
        @dsl = Stratiform::DSL.new
      rescue
        puts 'Error loading your Stratifile! Fix the errors and try again.'
        raise
      end
    end

    option :profile, desc: 'AWS CLI profile to use', default: 'default'
    option :region, desc: 'AWS region to use'

    desc 'create', 'Create a stack'
    def create(target, stack)
      invoke startup_tasks
      @dsl.run_create(target, stack)
    end

    no_tasks do
      def startup_tasks
        option_region, option_profile = options.values_at(:region, :profile)
        load_dsl
        mfa_code = prompt_for_mfa if AWSConfig.mfa_required?(option_profile)
        @aws_config = AWSConfig.new(option_region, option_profile, mfa_code)
      end

      def load_dsl
        @dsl.load_stratifile
      rescue
        puts 'Error loading your Stratifile! Fix the errors and try again.'
        raise
      end

      def prompt_for_mfa
        ask('Enter MFA code:', echo: false)
      end
    end
  end
end
