# frozen_string_literal: true

# Mock data for testing and defaults
module TodoApp
  module Mocks
    SESSION = {
      lists: [
        { name: 'default list',
          todos: [
            { name: 'default todo', done: false }
          ] }
      ]
    }.freeze
  end
end
