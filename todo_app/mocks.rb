# frozen_string_literal: true

require 'random/formatter'

# Mock data for testing and defaults
module TodoApp
  module Mocks
    SESSION = {
      lists: [
        {
          id: Random.uuid,
          name: 'default list',
          todos: [
            { id: Random.uuid, name: 'default todo', done: false }
          ]
        }
      ]
    }.freeze
  end
end
