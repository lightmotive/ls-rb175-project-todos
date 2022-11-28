# frozen_string_literal: true

module Steps
  class Message
    attr_accessor :abort_sequence
    alias abort_sequence? abort_sequence

    def initialize(message, abort_sequence: false)
      @message = message
      @abort_sequence = abort_sequence
    end

    def text
      @message
    end
  end
end
