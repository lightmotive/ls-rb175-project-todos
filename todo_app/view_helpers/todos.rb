# frozen_string_literal: true

module TodoApp
  module ViewHelpers
    # List collection helpers
    module Todos
      # Yield todo items and their original index in ordered groups:
      # Incomplete, Complete
      def todos_sorted_enum(todos, &block)
        complete_todos, incomplete_todos =
          todos.each_with_index.partition { |(todo, _idx)| todo[:done] }

        incomplete_todos.each(&block)
        complete_todos.each(&block)
      end
    end
  end
end
