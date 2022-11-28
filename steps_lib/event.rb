# frozen_string_literal: true

module Steps
  # Step-specific data (message and `Sequence` instructions) that a `Step` can
  # throw during `Sequence` iteration.
  class Event
    attr_accessor :message, :abort_sequence
    alias abort_sequence? abort_sequence

    def initialize(message, abort_sequence: false)
      @message = message
      @abort_sequence = abort_sequence
    end
  end
end
