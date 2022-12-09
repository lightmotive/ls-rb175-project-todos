# frozen_string_literal: true

require_relative '../step'

module Sequence
  module Common
    # Validate that the size of an object is between a min and max.
    class EnsureLengthBetween < Step
      def initialize(min, max, error_message = nil, value_name: 'Value')
        super()

        @min = min
        @max = max
        @value_name = value_name
        @error_message = error_message || "#{value_name} length must be between #{min} and #{max}."
      end

      def process(object)
        throw_failure(@error_message) unless object.length.between?(@min, @max)

        object
      end
    end
  end
end
