# frozen_string_literal: true

require_relative '../step'

module Steps
  module Common
    # Invoke `strip` on object.
    class Strip < Step
      def process(object)
        object.strip
      end
    end
  end
end
