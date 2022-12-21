# frozen_string_literal: true

require_relative 'events'

module Sequence
  # Sequentially process an object using an enumerable collection of
  # `Step`-like objects.
  #
  # `::new(enumerable_of_step)` - each `step` element must:
  # - Be one of the following:
  #   - A class that can be initialized with no arguments (`element.is_a?(Class)`).
  #   - A class instance.
  # - AND have a `process` method that:
  #   - Returns the object after processing.
  #   - OR `throw(:step_failure, Event)`.
  # `#process(object)` - return object after processing through steps.
  class Sequence
    def initialize(steps)
      raise StandardError, 'Initialize with an array containing at least 1 step.' if steps.empty?

      @steps = steps
      @failure_events = []
    end

    # Sequentially process object through steps sequence in the order provided
    # during class init.
    # - Returns the processed object if no step throws `:step_failure`.
    # - Otherwise, will `throw(:failure, Events instance)`.
    #   `Events` instance contains events that explaining what failed.
    def process(object)
      @failure_events = []

      @steps.each do |step|
        break if catch(:abort_sequence) do
                   object = execute_step(object, step)
                   false
                 end
      end

      @failure_events.empty? ? object : throw(:failure, Events.new(@failure_events))
    end

    private

    def execute_step(object, step)
      step = initialize_step(step)
      event = catch(:step_failure) do
        return step.process(object)
      end
      process_failure(event)
    end

    def initialize_step(step)
      return step.new if step.is_a?(Class)

      step
    end

    def process_failure(event)
      @failure_events << event
      throw(:abort_sequence, true) if event.abort_sequence?
    end
  end
end
