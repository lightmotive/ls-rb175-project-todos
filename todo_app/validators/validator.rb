# frozen_string_literal: true

require_relative 'validation_error'

module TodoApp
  module Validators
    # Base class for validators.
    class Validator
      attr_accessor :error_message

      def initialize(error_message = nil)
        @error_message = error_message || "#{self.class.name} error."
      end

      protected

      def raise_validation_error
        raise ValidationError, error_message
      end
    end
  end
end
