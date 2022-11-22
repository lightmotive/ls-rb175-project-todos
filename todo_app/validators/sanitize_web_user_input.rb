# frozen_string_literal: true

require_relative 'validator'
require_relative 'validation_error'
require 'sanitize'

module TodoApp
  module Validators
    # Validate a web user's input, modifying or stripping unsafe content as needed.
    class SanitizeWebUserInput < Validator
      def initialize(error_message = 'Invalid input.')
        super(error_message)
      end

      def validate(value)
        Sanitize.fragment(value)
      end
    end
  end
end
