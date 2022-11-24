# frozen_string_literal: true

module Steps
  class Message
    attr_accessor :skip_remaining_steps
    alias skip_remaining_steps? skip_remaining_steps

    def initialize(message, skip_remaining_steps: false)
      @message = message
      @skip_remaining_steps = skip_remaining_steps
    end

    def text
      @message
    end
  end
end
