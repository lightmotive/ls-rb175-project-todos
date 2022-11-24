# frozen_string_literal: true

require_relative 'message'

module Steps
  # Base class for steps that are designed to sequentially process an object.
  class Step
    def throw_failure(message)
      message = Message.new(message) if message.is_a?(String)

      throw(:step_failure, message)
    end

    def throw_failure_and_skip_remaining_steps(message)
      message = Message.new(message) if message.is_a?(String)
      message.skip_remaining_steps = true

      throw(:step_failure, message)
    end
  end
end
