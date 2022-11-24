# frozen_string_literal: true

require_relative 'step'
require_relative 'message'

module Steps
  # Defer object processing to block.
  class Custom < Step
    # Provide a block that receives 2 params when step is executed: object, step
    # - Block must do one of the following:
    #   - Invoke `step.throw_failure(message)` or `throw(:step_failure, Steps::Message)`.
    #   - Return processed object.
    def initialize(&step_logic)
      super()
      raise ArgumentError, 'Please provide a block.' unless block_given?

      @step_logic = step_logic
    end

    def process(object)
      @step_logic.call(object, self)
    end
  end
end
