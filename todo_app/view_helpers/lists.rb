# frozen_string_literal: true

require './todo_app/view_helpers/list'

module TodoApp
  module ViewHelpers
    # List collection helpers
    module Lists
      # Yield list items and their original index in ordered groups:
      # Incomplete, Complete
      def lists_sorted_enum(lists, &block)
        complete_lists, incomplete_lists =
          lists.partition { |list| list_complete?(list) }

        incomplete_lists.each(&block)
        complete_lists.each(&block)
      end
    end
  end
end
