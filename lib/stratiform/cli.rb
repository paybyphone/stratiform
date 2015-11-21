require 'stratiform/main'
require 'stratiform/awsconfig'
require 'thor'
require 'inifile'

module Stratiform
  # CLI class for stratiform and main entry point
  class CLI < Thor
    option :profile, desc: 'AWS CLI profile to use', default: 'default'
    option :region, desc: 'Default AWS region to use'
    option :path, desc: 'Path to Stratifile', default: 'Stratifile'

    desc 'create', 'Create a stack'
    def create(target, stack)
      mfa_code = prompt_for_mfa
      main = Main.new(option[:path])
      main.load_aws_config(mfa_code, option[:region], option[:profile])
      main.run_create(target, stack)
    end

    no_tasks do
      def prompt_for_mfa
        return nil unless AwsConfig.mfa_required(options[:profile])
        ask('Enter MFA code:', echo: false)
      end
    end
  end
end
