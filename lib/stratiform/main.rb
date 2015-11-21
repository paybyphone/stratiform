require 'stratiform/awsconfig'

module Stratiform
  # Main logic interface - ties CLI, DSL, and providers together
  class Main
    attr_reader :dsl, :default_region

    # Loads content if content is provided.
    def initialize(path: nil, region: nil, profile: 'default')
      @dsl = DSL.new
      @default_region = Stratiform::AwsConfig.default_region(
        option_region: region,
        profile: profile
      )
      load_dsl(path: path) if path
    end

    # Loads DSL from suppiled content.
    def load_dsl(path:)
      full_path = File.expand_path(path)
      @dsl.instance_eval(IO.read(full_path), full_path)
    rescue
      puts "Error loading Stratifile at #{full_path}. Check path, " \
           'and errors, and try again.'
      raise
    end

    # Loads values for and sets initial state on Aws.config
    def load_aws_config(mfa_code: nil, profile: nil)
      Stratiform::AwsConfig.default_credentials(
        profile: profile,
        mfa_code: mfa_code
      )
      Stratiform::AwsConfig.update_region(region: @default_region)
    end

    # Performs any target-related actions that need to happen before a stack
    # is acted upon, such as changing region, or assuming a new role.
    def prerun_actions(target_name:)
      target = @dsl.targets[target_name]
      role_arn = target.role_arn
      region = target.region
      Stratiform::AwsConfig.assume_aws_role(role_arn: role_arn) if role_arn
      Stratiform::AwsConfig.update_region(region: region) if region
    end

    # Performs any target-related actions that need to happen after a stack
    # is acted upon, such as restoring the default session state.
    def postrun_actions
      Stratiform::AwsConfig.reset_credentials
      Stratiform::AwsConfig.update_region(region: @default_region)
    end

    # Runs create for a stack.
    def run_create(target_name:, stack_name:)
      prerun_actions(target_name: target_name)
      stack = @dsl.stacks[stack_name]
      unless stack.targets.include?(target_name)
        fail(
          IndexError,
          "target #{target_name} is not a member of stack #{stack_name}"
        )
      end
      stack.create_stack
      postrun_actions
    end
  end
end
