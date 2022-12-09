# frozen_string_literal: true

require_relative 'event'

module Sequence
  # Base class for a step in a sequence that's designed to sequentially process
  # an object.
  class Step
    def throw_failure(message)
      message = Event.new(message) if message.is_a?(String)

      throw(:step_failure, message)
    end

    def throw_failure_and_abort_sequence(message)
      message = Event.new(message) if message.is_a?(String)
      message.abort_sequence = true

      throw(:step_failure, message)
    end
  end
end
