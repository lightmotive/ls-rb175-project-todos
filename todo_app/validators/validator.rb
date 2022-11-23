# frozen_string_literal: true

require_relative 'validation_error'

module TodoApp
  module Validators
    # Base class for validators that are designed to execute sequentially.
    class Validator
      attr_accessor :error_message

      def initialize(error_message = nil)
        @error_message = error_message || "#{self.class.name.split('::').last} error."
      end

      # Override to return `true` if a specific Validator instance should skip
      # subsequent validations when validation/processing fails.
      def skip_subsequent_validations_after_exception?
        false
      end

      protected

      def raise_validation_error
        raise ValidationError, error_message
      end
    end
  end
end
