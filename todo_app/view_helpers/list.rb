# frozen_string_literal: true

module TodoApp
  module ViewHelpers
    # List object helpers
    module List
      def list_todos_count(list)
        list[:todos].size
      end

      def list_todos_count_by_done(list:, is_done:)
        list[:todos].count { |todo| todo[:done] == is_done }
      end

      def list_complete?(list)
        all_todos_done = list[:todos].all? { |todo| todo[:done] }
        list_todos_count(list).positive? && all_todos_done
      end

      def list_completable?(list)
        return false unless list_todos_count(list).positive?

        list[:todos].any? { |todo| !todo[:done] }
      end

      def list_container_css_class(list)
        'complete' if list_complete?(list)
      end
    end
  end
end
