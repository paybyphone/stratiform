require 'stratiform/helpers/aws'

module Stratiform
  # Stack resource - define stacks that are going to be created.
  class Stack
    include Stratiform::Helpers::Aws

    def initialize(name, &block)
      @name = name
      instance_eval(&block) unless block.nil?
    end

    def name(arg = nil)
      @name = arg unless arg.nil?
      @name
    end

    def targets(arg = nil)
      @targets = arg unless arg.nil?
      @targets
    end

    def template_data(arg = nil)
      @template_data = arg unless arg.nil?
      @template_data
    end

    def parameters(arg = nil)
      @parameters = arg unless arg.nil?
      @parameters
    end

    def validate_template(target)
      cloudformation = cloudformation_client(
        target.region,
        target.target_credentials
      )
      cloudformation.validate_template(template_body: read_template)
    end

    def create_stack(target)
      cloudformation = cloudformation_client(
        target.region,
        target.target_credentials
      )
      resp = cloudformation.create_stack(
        stack_name: @name,
        template_body: read_template
      )
      resp.stack_id
    end

    def read_template
      IO.read("stratiform/#{@name}.tpl")
    end
  end
end
