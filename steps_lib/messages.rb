# frozen_string_literal: true

module Steps
  # A collection of Step-provided `Message` instances.
  class Messages
    attr_reader :messages

    def initialize(messages)
      @messages = messages
    end

    def as_text
      messages.map(&:text).join("\n")
    end

    def as_html(wrapper_div_class: nil)
      "<div#{wrapper_div_class ? "class=\"#{wrapper_div_class}\"" : ''}>\n" \
      "<div>#{messages.map(&:text).join("</div>\n<div>")}</div>\n" \
      '</div>'
    end
  end
end
