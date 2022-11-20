# frozen_string_literal: true

require 'sanitize'

module SanitizeUserInput
  def sanitize_fragment(fragment)
    Sanitize.fragment(fragment)
  end
end
