# frozen_string_literal: true

require_relative 'validator'
require_relative 'validation_error'

module TodoApp
  module Validators
    # Defer validation to block.
    class Custom < Validator
      # Block must either raise `ValidationError` exception or return validated value.
      def initialize(error_message = nil, &block_validate)
        super(error_message)

        @block_validate = block_validate
      end

      def validate(value)
        @block_validate.call(value)
      end
    end
  end
end
