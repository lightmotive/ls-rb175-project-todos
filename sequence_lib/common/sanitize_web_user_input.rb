# frozen_string_literal: true

require_relative '../step'
require 'sanitize'

module Sequence
  module Common
    # Validate a web user's input, modifying or stripping unsafe content as needed.
    class SanitizeWebUserInput < Step
      def process(object)
        Sanitize.fragment(object)
      end
    end
  end
end
