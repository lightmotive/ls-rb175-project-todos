# frozen_string_literal: true

require_relative 'messages'

module Steps
  # Sequentially process an object using an enumerable collection of
  # `Step`-derived objects.
  #
  # `::new([step])` - each `step` element must:
  # - Be one of the following:
  #   - A class that can be initialized with no arguments (`element.is_a?(Class)`).
  #   - A class instance.
  # - AND have a `process` method that:
  #   - Returns the object after processing.
  #   - OR `throw(:step_failure, Message)`.
  # `#process(object)` - return object after processing through steps.
  class Sequence
    def initialize(steps)
      raise StandardError, 'Initialize with an array containing at least 1 step.' if steps.empty?

      @steps = steps
      @failure_messages = []
    end

    # Sequentially process object through steps in order provided during class init.
    # - Returns the processed object if no step throws `:step_failure`.
    # - Otherwise, will `throw(:failure, Messages instance)`.
    #   `Messages` instance contains messages explaining what failed.
    def process(object)
      @failure_messages = []

      @steps.each do |step|
        break if catch(:skip_remaining_steps) do
                   object = execute_step(object, initialize_step(step))
                   false
                 end
      end

      @failure_messages.empty? ? object : throw(:failure, Messages.new(@failure_messages))
    end

    private

    def initialize_step(step)
      return step.new if step.is_a?(Class)

      step
    end

    def execute_step(object, step)
      message = catch(:step_failure) do
        return step.process(object)
      end
      process_failure(message)
    end

    def process_failure(message)
      @failure_messages << message
      throw(:skip_remaining_steps, true) if message.skip_remaining_steps?
    end
  end
end
