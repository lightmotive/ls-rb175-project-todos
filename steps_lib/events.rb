# frozen_string_literal: true

module Steps
  # A `Sequence`-collected array of `Step`-thrown `Event` instances.
  class Events
    attr_reader :events

    def initialize(events)
      @events = events
    end

    def messages_as_text
      messages_as_array.join("\n")
    end

    def messages_as_array
      events.map(&:message)
    end
  end
end
