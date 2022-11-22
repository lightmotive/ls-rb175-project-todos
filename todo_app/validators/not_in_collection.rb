# frozen_string_literal: true

require_relative 'validator'
require_relative 'validation_error'

module TodoApp
  module Validators
    # Validate that a value is not in a collection.
    class NotInCollection < Validator
      def initialize(collection, error_message = 'The value must be unique.')
        super(error_message)

        @collection = collection
      end

      def validate(value)
        raise_validation_error if @collection.include?(value)

        value
      end
    end
  end
end
