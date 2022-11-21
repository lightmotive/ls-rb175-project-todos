# frozen_string_literal: true

require 'sanitize'

# Use 'sanitize' Gem to validate user input in a consistent manner.
module SanitizeUserInput
  def sanitize_fragment(fragment)
    Sanitize.fragment(fragment)
  end
end
