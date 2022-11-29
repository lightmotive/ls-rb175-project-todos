# frozen_string_literal: true

require_relative 'step'
require_relative 'event'

module Steps
  # Defer object processing to block.
  class Custom < Step
    # Provide a block that receives 2 params when step is executed: object, step
    # - Block must do one of the following:
    #   - Invoke one:
    #     - `Step#throw_failure(message_string)`
    #     - `throw(:step_failure, Steps::Event.new(message_string[, abort_sequence: true]))`.
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
