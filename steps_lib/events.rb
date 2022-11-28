# frozen_string_literal: true

module Steps
  # A `Sequence`-collected array of `Step`-thrown `Event` instances.
  class Events
    attr_reader :events

    def initialize(events)
      @events = events
    end

    def as_text
      events.map(&:message).join("\n")
    end

    def as_html(wrapper_div_class: nil)
      "<div#{wrapper_div_class ? "class=\"#{wrapper_div_class}\"" : ''}>\n" \
      "<div>#{events.map(&:message).join("</div>\n<div>")}</div>\n" \
      '</div>'
    end
  end
end
