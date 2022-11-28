# frozen_string_literal: true

require_relative 'message'

module Steps
  # Base class for steps that are designed to sequentially process an object.
  class Step
    def throw_failure(message)
      message = Message.new(message) if message.is_a?(String)

      throw(:step_failure, message)
    end

    def throw_failure_and_abort_sequence(message)
      message = Message.new(message) if message.is_a?(String)
      message.abort_sequence = true

      throw(:step_failure, message)
    end
  end
end
