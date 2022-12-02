# frozen_string_literal: true

module TodoApp
  module ViewHelpers
    # Layout view helpers
    module Layout
      def session_flash_messages(content)
        if content.is_a?(Array)
          return "<p>#{content.join('</p><p>')}</p>" if content.size <= 1

          '<ul>' \
          "<li>#{content.join('</li><li>')}</li>" \
          '</ul>'
        elsif content.is_a?(String)
          "<p>#{content}</p>"
        else
          raise 'Flash message content must be an array of strings or a string.'
        end
      end
    end
  end
end
