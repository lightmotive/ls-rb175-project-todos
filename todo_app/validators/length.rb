# frozen_string_literal: true

require_relative 'validator'
require_relative 'validation_error'

module TodoApp
  module Validators
    # Validate that the size of something is between a min and max.
    class Length < Validator
      def initialize(min, max, error_message = nil, value_name: 'Value')
        super(error_message || "#{value_name} length must be between #{min} and #{max}.")

        @min = min
        @max = max
        @value_name = value_name
      end

      def validate(value)
        raise_validation_error unless value.length.between?(@min, @max)

        value
      end
    end
  end
end
