module Stratiform
  # Stack resource - define stacks that are going to be created.
  class Stack
    def initialize(name, &block)
      @name = name
      instance_eval(&block) if block
    end

    def name(name_value = nil)
      @name = name_value if name_value
      @name
    end

    def targets(targets_value = nil)
      @targets = targets_value if targets_value
      @targets
    end

    def template_data(template_data_value = nil)
      @template_data = template_data_value if template_data_value
      @template_data
    end

    def parameters(parameters_value = nil)
      @parameters = parameters_value if parameters_value
      @parameters
    end

    def validate_template
      cloudformation = Aws::CloudFormation::Client.new
      cloudformation.validate_template(template_body: read_template)
    end

    def create_stack
      cloudformation = Aws::CloudFormation::Client.new
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
