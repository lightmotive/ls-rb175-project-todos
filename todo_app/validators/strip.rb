# frozen_string_literal: true

require_relative 'validator'
require_relative 'validation_error'

module TodoApp
  module Validators
    # Validate that the size of something is between a min and max.
    class Strip < Validator
      def validate(value)
        value.strip
      end
    end
  end
end
