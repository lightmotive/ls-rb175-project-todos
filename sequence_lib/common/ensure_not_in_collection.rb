# frozen_string_literal: true

require_relative '../step'

module Sequence
  module Common
    # Validate that an object is not in a collection.
    class EnsureNotInCollection < Step
      def initialize(collection, error_message = 'The object must be unique.')
        super()

        @collection = collection
        @error_message = error_message
      end

      def process(object)
        throw_failure(@error_message) if @collection.include?(object)

        object
      end
    end
  end
end
